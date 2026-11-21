#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pillow>=10.0"]
# ///
"""把图片压缩成 WebP，控制单文件体积与最长边。

用法:
    uv run tools/img2webp.py a.png b.jpg -o out/
    uv run tools/img2webp.py ./shots -o out/ --max-bytes 200k --max-side 1400
    uv run tools/img2webp.py https://example.com/x.png -o out/

所有输出都是 .webp；同名冲突时追加 `-2`、`-3`。透明通道保留。
体积超限时先降质量（88 → 45），仍超限再按比例缩小边长重试。
"""

from __future__ import annotations

import argparse
import hashlib
import io
import re
import sys
import urllib.request
from pathlib import Path
from urllib.parse import unquote, urlparse

from PIL import Image, ImageOps

DEFAULT_MAX_BYTES = 250_000
DEFAULT_MAX_SIDE = 1600
DEFAULT_QUALITY = 88
MIN_QUALITY = 45


def human_size(n: int) -> str:
    for unit in ("B", "KB", "MB"):
        if n < 1024 or unit == "MB":
            return f"{n:.0f}{unit}" if unit == "B" else f"{n / (1024 ** (1 if unit == 'KB' else 2)):.0f}{unit}"
        n_next = n / 1024
        if n_next < 1024:
            return f"{n_next:.0f}KB"
        n = int(n_next)
    return f"{n}B"


def parse_size(text: str) -> int:
    m = re.fullmatch(r"\s*(\d+(?:\.\d+)?)\s*([kKmM]?)\s*", text)
    if not m:
        raise argparse.ArgumentTypeError(f"无法解析体积: {text}")
    value = float(m.group(1))
    unit = m.group(2).lower()
    if unit == "k":
        value *= 1024
    elif unit == "m":
        value *= 1024 * 1024
    return int(value)


def _downscale(img: Image.Image, max_side: int) -> Image.Image:
    longest = max(img.size)
    if longest <= max_side:
        return img
    scale = max_side / longest
    size = (max(1, round(img.width * scale)), max(1, round(img.height * scale)))
    return img.resize(size, Image.LANCZOS)


def _flatten_mode(img: Image.Image) -> Image.Image:
    if img.mode in ("RGBA", "LA"):
        return img.convert("RGBA")
    if img.mode == "P":
        return img.convert("RGBA" if "transparency" in img.info else "RGB")
    return img.convert("RGB")


def _encode(img: Image.Image, quality: int) -> bytes:
    buf = io.BytesIO()
    img.save(buf, "WEBP", quality=quality, method=6)
    return buf.getvalue()


def compress_bytes(
    data: bytes,
    max_bytes: int = DEFAULT_MAX_BYTES,
    max_side: int = DEFAULT_MAX_SIDE,
    quality: int = DEFAULT_QUALITY,
    min_quality: int = MIN_QUALITY,
) -> tuple[bytes, int, int, int]:
    """压缩内存中的图片。

    返回 (webp 字节, 宽, 高, 实际质量)。质量 0 表示走了无损编码。
    """
    with Image.open(io.BytesIO(data)) as raw:
        img = _flatten_mode(ImageOps.exif_transpose(raw))
        img = _downscale(img, max_side)

        # 小图 / 需要保留细节时优先无损，只要体积达标即可。
        try:
            lossless = io.BytesIO()
            img.save(lossless, "WEBP", lossless=True, method=6)
            if lossless.tell() <= max_bytes:
                return lossless.getvalue(), img.width, img.height, 0
        except Exception:
            pass

        for _ in range(6):
            for q in range(quality, min_quality - 1, -4):
                out = _encode(img, q)
                if len(out) <= max_bytes:
                    return out, img.width, img.height, q
            # 质量降到底还超限：缩小边长再来一轮。
            new_size = (max(1, int(img.width * 0.85)), max(1, int(img.height * 0.85)))
            if new_size == img.size:
                break
            img = img.resize(new_size, Image.LANCZOS)

        out = _encode(img, min_quality)
        return out, img.width, img.height, min_quality


def _safe_stem(name: str) -> str:
    stem = Path(unquote(name)).stem
    stem = re.sub(r"[^\w\-.\u4e00-\u9fff]+", "-", stem).strip("-._")
    if not stem:
        stem = "image"
    if len(stem) > 60:
        stem = stem[:60].rstrip("-._")
    return stem


def _unique_path(out_dir: Path, stem: str) -> Path:
    candidate = out_dir / f"{stem}.webp"
    i = 2
    while candidate.exists():
        candidate = out_dir / f"{stem}-{i}.webp"
        i += 1
    return candidate


def _is_url(text: str) -> bool:
    return urlparse(text).scheme in ("http", "https")


def _fetch(url: str, timeout: float = 60) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 img2webp"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def _iter_inputs(inputs: list[str]) -> list[str]:
    items: list[str] = []
    for raw in inputs:
        if _is_url(raw):
            items.append(raw)
            continue
        p = Path(raw)
        if p.is_dir():
            items.extend(str(x) for x in sorted(p.rglob("*")) if x.is_file())
        elif p.is_file():
            items.append(str(p))
        else:
            print(f"  ! 找不到输入: {raw}", file=sys.stderr)
    return items


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="把图片压缩转换为 WebP")
    parser.add_argument("inputs", nargs="+", help="图片文件、目录或 http(s) URL")
    parser.add_argument("-o", "--output-dir", default="webp", help="输出目录（默认 ./webp）")
    parser.add_argument("--max-bytes", type=parse_size, default=DEFAULT_MAX_BYTES,
                        help="单张图片体积上限，支持 200k/1m 写法（默认 250k）")
    parser.add_argument("--max-side", type=int, default=DEFAULT_MAX_SIDE,
                        help="最长边上限，超出则等比缩小（默认 1600）")
    parser.add_argument("--quality", type=int, default=DEFAULT_QUALITY,
                        help="起始质量，超限时自动下调（默认 88）")
    parser.add_argument("--name", help="只处理单个输入时，指定输出文件名（不含 .webp）")
    args = parser.parse_args(argv)

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    inputs = _iter_inputs(args.inputs)
    if not inputs:
        print("没有可处理的输入", file=sys.stderr)
        return 1

    ok = fail = 0
    total_before = total_after = 0
    for item in inputs:
        try:
            data = _fetch(item) if _is_url(item) else Path(item).read_bytes()
        except Exception as exc:
            print(f"  ✗ 读取失败 {item}: {exc}", file=sys.stderr)
            fail += 1
            continue

        try:
            webp, width, height, used_q = compress_bytes(
                data, args.max_bytes, args.max_side, args.quality
            )
        except Exception as exc:
            print(f"  ✗ 转换失败 {item}: {exc}", file=sys.stderr)
            fail += 1
            continue

        if args.name and len(inputs) == 1:
            target = out_dir / f"{_safe_stem(args.name)}.webp"
        else:
            source_name = urlparse(item).path if _is_url(item) else item
            stem = _safe_stem(source_name)
            if _is_url(item) and stem in ("", "image"):
                stem = hashlib.sha1(item.encode()).hexdigest()[:10]
            target = _unique_path(out_dir, stem)

        target.write_bytes(webp)
        total_before += len(data)
        total_after += len(webp)
        ok += 1
        mode = "无损" if used_q == 0 else f"q={used_q}"
        print(f"  ✓ {target.name}  {human_size(len(data))} → {human_size(len(webp))}  "
              f"{width}x{height}  {mode}")

    print(f"\n完成: {ok} 张成功, {fail} 张失败; 总计 "
          f"{human_size(total_before)} → {human_size(total_after)}")
    return 0 if fail == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
