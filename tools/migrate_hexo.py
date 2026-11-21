#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pillow>=10.0"]
# ///
"""把 D:/blog (Hexo) 的 Markdown 文章迁移到当前 Typst 博客。

流程:
    1. 解析 Hexo frontmatter（兼容缺起始 `---`、`>-` 折叠块、列表分类）。
    2. 下载文章里的外链图片（七牛云等），压缩成 WebP 存到文章目录 `assets/`。
    3. 把图片地址改写成本地相对路径，把旧站 `/posts/<abbrlink>/` 链接改写成本站链接。
    4. 用 pandoc 把 Markdown 转成 Typst，加模板头，写入 `content/<Section>/<slug>/index.typ`。
    5. 重建 `content/<Section>/index.typ` 的文章索引（与已有条目合并、按年份倒序）。

用法:
    uv run tools/migrate_hexo.py --dry-run          # 只解析，不下载不写文件
    uv run tools/migrate_hexo.py --only 论文阅读    # 只迁移路径包含该串的文章
    uv run tools/migrate_hexo.py                    # 全量迁移

依赖外部 pandoc: 放到 PATH，或 tools/bin/pandoc(.exe)。
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))
from img2webp import _safe_stem, compress_bytes

DEFAULT_OLD = Path("D:/blog/source/_posts")
DEFAULT_NEW = Path(".")

MAX_IMAGE_BYTES = 250_000
MAX_IMAGE_SIDE = 1600
IMAGE_QUALITY = 88

# 顶级分类 -> 新站栏目
STUDY_CATEGORIES = {
    "学习笔记",
    "算法学习",
    "数据结构",
    "编程语言学习",
    "linux系统编程学习",
    "论文阅读",
    "开源代码学习",
}
# 这些标题在新站已有重写版本，跳过旧稿
SKIP_TITLES = {"个人博客搭建指南", "考研经验分享", "碎碎念", "CCF-CSP助教"}
# 整个分类不迁移（导航贴已由用户删除）
SKIP_CATEGORIES = {"导航贴"}
THOUGHTS_TITLES = {"碎碎念"}

HEADER_TEMPLATE = (
    '#import "../../index.typ": template, tufted\n'
    '#show: template.with(title: "{title}")\n\n'
)


@dataclass
class Post:
    src: Path
    title: str
    date: datetime
    abbrlink: str
    categories: list[str]
    body: str
    section: str = ""
    slug: str = ""
    images: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    @property
    def rel_path(self) -> str:
        return f"/{self.section}/{self.slug}/"


# ---------------------------------------------------------------- frontmatter

def _unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def split_frontmatter(text: str) -> tuple[str, str]:
    """返回 (frontmatter, body)。兼容没有起始 `---` 的文件。"""
    text = text.lstrip("\ufeff")
    lines = text.splitlines(keepends=True)
    if not lines:
        return "", text

    if lines[0].strip() == "---":
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                return "".join(lines[1:i]), "".join(lines[i + 1:])

    # 没有起始分隔符：第一条非空行必须是 key:，结束于 `---` 行
    first = next((ln for ln in lines if ln.strip()), "")
    if re.match(r"^[A-Za-z0-9_-]+:", first):
        for i, line in enumerate(lines[:100]):
            if i > 0 and line.strip() == "---":
                return "".join(lines[:i]), "".join(lines[i + 1:])
    return "", text


def parse_meta(fm: str) -> dict[str, Any]:
    meta: dict[str, Any] = {}
    lines = fm.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        i += 1
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        m = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not m:
            continue
        key, value = m.group(1), m.group(2).strip()
        if value in (">-", ">", "|", "|-"):
            parts = []
            while i < len(lines) and (lines[i].startswith((" ", "\t")) or not lines[i].strip()):
                parts.append(lines[i].strip())
                i += 1
            meta[key] = " ".join(p for p in parts if p)
        elif value == "":
            items = []
            while i < len(lines) and re.match(r"^\s+-\s+", lines[i]):
                items.append(_unquote(re.sub(r"^\s+-\s+", "", lines[i])))
                i += 1
            meta[key] = items
        else:
            meta[key] = _unquote(value)
    return meta


def parse_date(value: str) -> datetime:
    for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M", "%Y-%m-%d"):
        try:
            return datetime.strptime(value.strip(), fmt)
        except ValueError:
            continue
    raise ValueError(f"无法解析日期: {value!r}")


def load_posts(old_root: Path) -> list[Post]:
    posts: list[Post] = []
    for path in sorted(old_root.rglob("*.md")):
        raw = path.read_text(encoding="utf-8", errors="replace")
        fm, body = split_frontmatter(raw)
        meta = parse_meta(fm)
        title = str(meta.get("title", "")).strip()
        if not title:
            print(f"  ! 跳过（无标题）: {path}")
            continue
        cats = meta.get("categories")
        categories = [str(c) for c in cats] if isinstance(cats, list) else ([str(cats)] if cats else [])
        abbrlink = re.sub(r"[^0-9A-Za-z]", "", str(meta.get("abbrlink", ""))) or hashlib.md5(
            path.name.encode("utf-8")
        ).hexdigest()[:8]
        try:
            date = parse_date(str(meta.get("date", "")))
        except ValueError as exc:
            print(f"  ! {path}: {exc}")
            continue
        posts.append(Post(path, title, date, abbrlink, categories, body))
    return posts


def classify(post: Post) -> str:
    if post.title in THOUGHTS_TITLES:
        return "Thoughts"
    if post.categories and post.categories[0] in STUDY_CATEGORIES:
        return "Study"
    return "Blog"


# ------------------------------------------------------------------- rewriting

OLD_LINK = re.compile(
    r"https?://(?:www\.)?ghost-him\.com/posts/([0-9A-Za-z]+)/?(?:#[^\s)\"'<>]*)?"
)
OLD_OTHER = [
    (re.compile(r"https?://(?:www\.)?ghost-him\.com/about/?", re.I), "/About/"),
    (re.compile(r"https?://(?:www\.)?ghost-him\.com/?$", re.I), "/"),
    (re.compile(r"(?<![\w.])www\.ghost-him\.com(?![\w.])", re.I), "https://ghost-him.github.io/"),
]
IMG_MD = re.compile(r"!\[([^\]]*)\]\(([^()\n]*)\)")
IMG_HTML = re.compile(r"<img\b([^>]*?)/?>", re.I | re.S)
ATTR = re.compile(r"(\w+)\s*=\s*\"([^\"]*)\"|(\w+)\s*=\s*'([^']*)'")


def _md_dest(raw: str) -> str:
    raw = raw.strip()
    raw = re.sub(r'\s+"[^"]*"$', "", raw).strip()
    if raw.startswith("<") and raw.endswith(">"):
        raw = raw[1:-1].strip()
    return raw


def html_img_to_md(match: re.Match[str]) -> str:
    attrs = {m.group(1) or m.group(3): (m.group(2) if m.group(1) else m.group(4))
             for m in ATTR.finditer(match.group(1))}
    src = attrs.get("src", "")
    alt = attrs.get("alt", "")
    return f"![{alt}]({src})" if src else ""


def asset_name(url: str) -> str:
    path = urllib.parse.urlparse(url).path
    stem = _safe_stem(path) or "image"
    return f"{stem}-{hashlib.sha1(url.encode('utf-8')).hexdigest()[:8]}.webp"


def _html_src(match: re.Match[str]) -> str:
    for m in ATTR.finditer(match.group(1)):
        if (m.group(1) or m.group(3)) == "src":
            return m.group(2) if m.group(1) else m.group(4)
    return ""


def collect_image_urls(body: str) -> list[str]:
    body_no_html = IMG_HTML.sub("", body)
    urls = [_md_dest(m.group(2)) for m in IMG_MD.finditer(body_no_html)]
    urls += [_html_src(m) for m in IMG_HTML.finditer(body)]
    out: list[str] = []
    for u in urls:
        if u.startswith(("http://", "https://")) and u not in out:
            out.append(u)
    return out


def mirror_urls(url: str) -> list[str]:
    """直连失败的图片依次尝试可用的镜像/解码地址。"""
    candidates = [url]

    # GitHub camo 地址里是十六进制编码的原图 URL
    m = re.search(r"camo\.githubusercontent\.com/[0-9a-f]+/([0-9a-f]+)$", url)
    if m:
        try:
            candidates.append(bytes.fromhex(m.group(1)).decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            pass

    # raw.githubusercontent.com -> jsDelivr
    if "raw.githubusercontent.com" in url:
        parts = urllib.parse.urlparse(url).path.lstrip("/").split("/")
        if len(parts) >= 4:
            candidates.append(
                f"https://cdn.jsdelivr.net/gh/{parts[0]}/{parts[1]}@{parts[2]}/" + "/".join(parts[3:])
            )

    # medium 的 resize/format 前缀可以去掉
    if "miro.medium.com" in url:
        candidates.append(re.sub(r"/v2/resize:[^/]+/format:[^/]+/", "/v2/", url))

    # 通用图片代理兜底（GitHub 直连、medium CDN 在部分网络下不可达）
    if any(host in url for host in ("raw.githubusercontent.com", "miro.medium.com")):
        candidates.append("https://wsrv.nl/?url=" + urllib.parse.quote(url, safe=""))

    return candidates


def fetch(url: str, tries: int = 2) -> bytes:
    safe_urls = [
        urllib.parse.quote(u, safe=":/?#&=+%,;@!$'()*[]~-._") for u in mirror_urls(url)
    ]
    errors: list[str] = []
    for safe in safe_urls:
        for _ in range(tries):
            try:
                req = urllib.request.Request(safe, headers={"User-Agent": "Mozilla/5.0 migrate"})
                with urllib.request.urlopen(req, timeout=90) as resp:
                    return resp.read()
            except Exception as exc:  # noqa: BLE001
                errors.append(f"{safe}: {exc}")
    raise RuntimeError("; ".join(errors[-2:]))


def typst_string(text: str) -> str:
    return text.replace("\\", "\\\\").replace('"', '\\"')


def shift_headings(body: str, delta: int) -> str:
    if delta <= 0:
        return body
    out = []
    in_fence = False
    for line in body.splitlines(keepends=True):
        if line.lstrip().startswith(("```", "~~~")):
            in_fence = not in_fence
            out.append(line)
            continue
        if not in_fence:
            m = re.match(r"^(#{1,6})(\s+.*)$", line)
            if m:
                level = min(6, len(m.group(1)) - delta)
                out.append("#" * level + m.group(2))
                continue
        out.append(line)
    return "".join(out)


def rewrite_markdown(post: Post, body: str, url_to_rel: dict[str, str], link_map: dict[str, str]) -> str:
    body = IMG_HTML.sub(html_img_to_md, body)
    body = re.sub(r"<!--.*?-->", "", body, flags=re.S)

    def repl_img(m: re.Match[str]) -> str:
        alt, url = m.group(1), _md_dest(m.group(2))
        if url in url_to_rel:
            return f"![{alt}]({url_to_rel[url]})"
        post.warnings.append(f"图片未本地化，保留外链: {url}")
        return f"![{alt}]({url})"

    body = IMG_MD.sub(repl_img, body)

    def repl_link(m: re.Match[str]) -> str:
        abbr = m.group(1).lower()
        target = link_map.get(abbr)
        if target:
            return target
        post.warnings.append(f"旧站链接未找到对应文章: {m.group(0)}")
        return m.group(0)

    body = OLD_LINK.sub(repl_link, body)
    for pattern, replacement in OLD_OTHER:
        body = pattern.sub(replacement, body)
    return body


# --------------------------------------------------------------------- pandoc

def find_pandoc() -> str:
    local = Path(__file__).resolve().parent / "bin" / ("pandoc.exe" if os.name == "nt" else "pandoc")
    if local.exists():
        return str(local)
    found = shutil.which("pandoc")
    if found:
        return found
    raise SystemExit(
        "找不到 pandoc。请下载 pandoc 放到 tools/bin/，或安装后加入 PATH。\n"
        "  https://github.com/jgm/pandoc/releases"
    )


def md_to_typst(pandoc: str, markdown: str) -> str:
    proc = subprocess.run(
        [pandoc, "-f",
         "markdown+tex_math_dollars+implicit_figures+pipe_tables+strikeout"
         "+lists_without_preceding_blankline-blank_before_header-blank_before_blockquote",
         "-t", "typst", "--wrap=none"],
        input=markdown.encode("utf-8"),
        capture_output=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.decode("utf-8", "replace").strip())
    # Windows 版 pandoc 输出 CRLF，会破坏行尾锚定的后处理
    return proc.stdout.decode("utf-8").replace("\r\n", "\n").replace("\r", "\n")


def polish_typst(typst: str) -> str:
    # 无 alt 的独立图片：Pandoc 会包成 #box(image(...))，改成 figure 以命中模板样式
    typst = re.sub(
        r'(?m)^#box\(image\(("(?:[^"\\]|\\.)*")\)\)$', r"#figure(image(\1))", typst
    )
    # 独占一行的 plain image 包成 figure，让模板统一处理
    typst = re.sub(r'(?m)^#image\(("(?:[^"\\]|\\.)*")\)$', r"#figure(image(\1))", typst)
    # 行内图片：去掉 Pandoc 的 #box 包裹，保留行内语义（# 不能丢）
    typst = re.sub(r'#box\(image\(("(?:[^"\\]|\\.)*")\)\)', r'#image(\1)', typst)
    # Typst 0.14 的 HTML 导出会丢掉 align(...) 里的 table，拆掉这层包裹
    typst = re.sub(
        r"align\(center\)\[#table\((.*?)\n(\s*)\)\]",
        lambda m: "table(" + m.group(1) + "\n" + m.group(2) + ")",
        typst,
        flags=re.S,
    )
    # Pandoc 的 --- 会输出 #horizontalrule；Typst 的 #line 在 HTML 导出里不产生元素
    typst = typst.replace("#horizontalrule", "#html.hr()")
    # Pandoc 有时留下空 figure / 空 caption
    typst = re.sub(r"#figure\(\s*\)", "", typst)

    lines, out, in_fence, blanks = typst.splitlines(keepends=True), [], False, 0
    for line in lines:
        if line.lstrip().startswith(("```", "~~~")):
            in_fence = not in_fence
        if not in_fence:
            # 删除 Pandoc 自动生成的 <label>：旧站锚点对不上，非法字符还会编译失败
            if re.fullmatch(r"<[^<>\n]*>\s*\n?", line):
                continue
            # 折叠 2 行以上的连续空行
            if not line.strip():
                blanks += 1
                if blanks > 1:
                    continue
            else:
                blanks = 0
        out.append(line)
    return "".join(out).rstrip() + "\n"


# --------------------------------------------------------------------- index

ENTRY = re.compile(
    r'#tufted\.blog-entry\(date: datetime\(year: (\d{4}), month: (\d{1,2}), day: (\d{1,2})\), '
    r'path: "([^"]*)", title: "((?:[^"\\]|\\.)*)"\)'
)


def rebuild_index(index_path: Path, new_entries: list[tuple[int, int, int, str, str]]) -> None:
    text = index_path.read_text(encoding="utf-8") if index_path.exists() else ""
    if not text:
        return

    existing = ENTRY.findall(text)
    entries: list[tuple[int, int, int, str, str]] = []
    for y, m, d, path, title in existing:
        entries.append((int(y), int(m), int(d), path, title))
    entries.extend(new_entries)

    # 按 path 去重（保留已有条目）
    seen: set[str] = set()
    unique = []
    for entry in entries:
        key = entry[3].rstrip("/").lower()
        if key in seen:
            continue
        seen.add(key)
        unique.append(entry)
    # 目标文章已被删除的索引条目一并移除
    base = index_path.parent
    unique = [e for e in unique if (base / e[3].strip("/")).is_dir()]
    unique.sort(key=lambda e: (e[0], e[1], e[2]), reverse=True)

    cut = len(text)
    for m in re.finditer(r"(?m)^(==\s*\d{4}\s*$|#tufted\.blog-entry\()", text):
        cut = m.start()
        break
    head = text[:cut].rstrip() + "\n\n"

    lines: list[str] = []
    current_year = None
    for y, m, d, path, title in unique:
        if y != current_year:
            if current_year is not None:
                lines.append("\n")
            current_year = y
            lines.append(f"== {y}\n\n")
        if not path.endswith("/"):
            path += "/"
        lines.append(
            f"#tufted.blog-entry(date: datetime(year: {y}, month: {m}, day: {d}), "
            f'path: "{path}", title: "{title}")\n'
        )
    index_path.write_text(head + "".join(lines).rstrip() + "\n", encoding="utf-8")


# ---------------------------------------------------------------- image cache

IMAGE_CACHE = Path(tempfile.gettempdir()) / "hexo-migrate-image-cache"


def cached_fetch(url: str) -> bytes:
    key = IMAGE_CACHE / (hashlib.sha1(url.encode("utf-8")).hexdigest() + ".bin")
    if key.exists():
        return key.read_bytes()
    data = fetch(url)
    IMAGE_CACHE.mkdir(parents=True, exist_ok=True)
    key.write_bytes(data)
    return data


def process_images(
    posts: list[Post],
    new_root: Path,
    jobs: int,
    write: bool,
) -> tuple[dict[str, str], dict[str, list[str]]]:
    """下载并压缩所有图片，返回 (url -> 全局 webp 字节临时路径, 每篇的 url->相对路径)。"""
    all_urls: dict[str, list[str]] = {}
    for post in posts:
        post.images = collect_image_urls(post.body)
        for url in post.images:
            all_urls.setdefault(url, []).append(post.slug)

    print(f"需要下载 {len(all_urls)} 张唯一图片 ...")
    results: dict[str, bytes | None] = {}

    def work(url: str) -> tuple[str, bytes | None]:
        try:
            data = cached_fetch(url)
            webp, _w, _h, _q = compress_bytes(data, MAX_IMAGE_BYTES, MAX_IMAGE_SIDE, IMAGE_QUALITY)
            return url, webp
        except Exception as exc:  # noqa: BLE001
            print(f"  ✗ {url}\n    {exc}")
            return url, None

    with ThreadPoolExecutor(max_workers=jobs) as pool:
        for i, (url, data) in enumerate(pool.map(work, all_urls), 1):
            results[url] = data
            if i % 20 == 0 or i == len(all_urls):
                print(f"  进度 {i}/{len(all_urls)}")

    per_post: dict[str, dict[str, str]] = {}
    total_before = total_after = 0
    for post in posts:
        mapping: dict[str, str] = {}
        if post.images and write:
            assets = new_root / "content" / post.section / post.slug / "assets"
            assets.mkdir(parents=True, exist_ok=True)
        for url in post.images:
            data = results.get(url)
            if data is None:
                continue
            name = asset_name(url)
            mapping[url] = f"assets/{name}"
            if write:
                target = new_root / "content" / post.section / post.slug / "assets" / name
                target.write_bytes(data)
            total_after += len(data)
        per_post[post.slug] = mapping

    print(f"图片完成: {sum(1 for v in results.values() if v)} 张成功, "
          f"{sum(1 for v in results.values() if not v)} 张失败; 压缩后合计 "
          f"{total_after / 1024 / 1024:.1f} MB")
    return {u: (asset_name(u) if d else "") for u, d in results.items()}, per_post


# ---------------------------------------------------------------------- main

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Hexo Markdown -> Typst 博客迁移")
    parser.add_argument("--old", type=Path, default=DEFAULT_OLD, help="老博客 _posts 目录")
    parser.add_argument("--new", type=Path, default=DEFAULT_NEW, help="新博客根目录")
    parser.add_argument("--only", help="只处理路径/标题/slug 匹配该串(逗号分隔)的文章")
    parser.add_argument("--jobs", type=int, default=8, help="图片下载并发数")
    parser.add_argument("--dry-run", action="store_true", help="只解析和分类，不下载、不写文件")
    parser.add_argument("--skip-index", action="store_true", help="不改写栏目索引")
    args = parser.parse_args(argv)

    old_root: Path = args.old
    new_root: Path = args.new.resolve()
    if not old_root.exists():
        raise SystemExit(f"老博客目录不存在: {old_root}")

    posts = load_posts(old_root)
    skipped = []
    for post in posts:
        post.section = classify(post)
        post.slug = f"{post.date:%Y-%m-%d}-{post.abbrlink}"

    kept = []
    for post in posts:
        if post.title in SKIP_TITLES or (post.categories and post.categories[0] in SKIP_CATEGORIES):
            skipped.append(post)
            continue
        needles = [n.strip() for n in (args.only or "").split(",") if n.strip()]
        if needles and not any(
            n in str(post.src) or n in post.title or n in post.slug for n in needles
        ):
            continue
        kept.append(post)

    print(f"解析 {len(posts)} 篇，迁移 {len(kept)} 篇，跳过 {len(skipped)} 篇"
          f"（新站已有重写版）")
    for post in skipped:
        print(f"  跳过: {post.title}")

    dup = {}
    for post in kept:
        if post.slug in dup:
            raise SystemExit(f"slug 冲突: {post.slug} -> {post.src} / {dup[post.slug]}")
        dup[post.slug] = post.src

    if args.dry_run:
        for post in kept:
            print(f"  [{post.section}] {post.slug}  {post.title}  imgs={len(collect_image_urls(post.body))}")
        return 0

    pandoc = find_pandoc()
    print(f"pandoc: {pandoc}")

    _, per_post = process_images(kept, new_root, args.jobs, write=True)

    link_map = {post.abbrlink.lower(): post.rel_path for post in posts}

    ok = failed = 0
    for i, post in enumerate(kept, 1):
        out_dir = new_root / "content" / post.section / post.slug
        out_dir.mkdir(parents=True, exist_ok=True)
        levels = [len(m.group(1)) for m in re.finditer(r"(?m)^(#{1,6})\s", post.body)]
        delta = (min(levels) - 1) if levels else 0
        body = shift_headings(post.body, delta)
        md = rewrite_markdown(post, body, per_post.get(post.slug, {}), link_map)
        try:
            typst = polish_typst(md_to_typst(pandoc, md))
        except Exception as exc:  # noqa: BLE001
            print(f"  ✗ [{i}/{len(kept)}] pandoc 失败 {post.src.name}: {exc}")
            failed += 1
            continue
        header = HEADER_TEMPLATE.format(title=typst_string(post.title))
        (out_dir / "index.typ").write_text(header + typst, encoding="utf-8")
        ok += 1
        for warning in post.warnings:
            print(f"  ! {post.slug}: {warning}")
        if i % 20 == 0 or i == len(kept):
            print(f"  写入 {i}/{len(kept)}")

    print(f"文章完成: {ok} 篇成功, {failed} 篇失败")

    if not args.skip_index:
        by_section: dict[str, list[tuple[int, int, int, str, str]]] = {}
        for post in kept:
            by_section.setdefault(post.section, []).append(
                (post.date.year, post.date.month, post.date.day, f"{post.slug}/", typst_string(post.title))
            )
        # 所有已有栏目都要重建：本轮无新增文章的栏目也需要剔除已删除条目
        for section in ("Blog", "Study", "Thoughts"):
            index_path = new_root / "content" / section / "index.typ"
            if not index_path.exists():
                print(f"  ! 缺少栏目索引: {index_path}")
                continue
            entries = by_section.get(section, [])
            rebuild_index(index_path, entries)
            print(f"  索引已更新: {section} +{len(entries)} 条")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
