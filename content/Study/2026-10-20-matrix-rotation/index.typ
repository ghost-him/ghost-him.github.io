#import "../../index.typ": template, tufted
#show: template.with(title: "算法笔记：矩阵旋转（原地修改）")

= 算法笔记：矩阵旋转（原地修改）

这份笔记整理了矩阵旋转类题目的核心要点：核心公式、坐标映射、代码实现、变种题推导以及面试进阶技巧。

== 核心结论（秒杀口诀）

在要求*原地修改*（$O(1)$ 空间复杂度）的前提下，最不容易出 Bug、代码最短的“万能公式”是：

+ *顺时针旋转 90°* = 转置矩阵 + 水平翻转（左右镜像）
+ *逆时针旋转 90°* = 转置矩阵 + 垂直翻转（上下镜像）
+ *旋转 180°* = 水平翻转 + 垂直翻转（或直接中心对称互换）

💡 *转置矩阵*：沿*主对角线*（左上到右下）对称交换，即 `matrix[i][j]` 与 `matrix[j][i]` 互换。

== 坐标映射公式（纯数学推导）

假设矩阵为 $n times n$，原坐标为 `(i, j)`（`i` 是行，`j` 是列），新矩阵为 `new_matrix`。表中“赋值”表示把原图的值写到新矩阵，“原地”表示原地修改时目标位置该怎么取。

#figure(
  table(
    columns: (1fr, 1.15fr, 1.25fr, 1.25fr),
    align: (left, center, center, center),
    inset: 4pt,
    [*方向*], [*坐标映射*], [*赋值到新图*], [*原地修改*],
    [*顺时针 90°*], [`(i, j) -> (j, n - 1 - i)`], [`new[j][n - 1 - i] = matrix[i][j]`], [`matrix[i][j] = matrix[n - 1 - j][i]`],
    [*逆时针 90°*], [`(i, j) -> (n - 1 - j, i)`], [`new[n - 1 - j][i] = matrix[i][j]`], [`matrix[i][j] = matrix[j][n - 1 - i]`],
    [*旋转 180°*], [`(i, j) -> (n - 1 - i, n - 1 - j)`], [`new[n - 1 - i][n - 1 - j] = matrix[i][j]`], [`matrix[i][j] = matrix[n - 1 - i][n - 1 - j]`],
  ),
)

口诀：顺时针是“行变列，列倒悬”；逆时针是“列变行，行倒悬”；旋转 180° 是“中心对称，双倒悬”。

== 代码实现模板

以下代码默认已经包含 `<vector>` 与 `<algorithm>`，并 `using namespace std;`。

=== 顺时针旋转 90°（LeetCode 48）

*方法 A：转置 + 水平翻转（推荐，最易懂）*

```cpp
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();

        // 1. 转置矩阵（沿主对角线）
        for (int i = 0; i < n; ++i) {
            // 注意 j 从 i + 1 开始
            for (int j = i + 1; j < n; ++j) {
                swap(matrix[i][j], matrix[j][i]);
            }
        }

        // 2. 水平翻转（每行左右互换）
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n / 2; ++j) {
                swap(matrix[i][j], matrix[i][n - 1 - j]);
            }
        }
    }
};
```

*方法 B：利用 STL 标准库（更短）*

C++ 没有 Python 里 `zip(*matrix)` 那种真正的一行流；不过借助 `std::reverse`，可以比方法 A 写得更短。

```cpp
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();

        // 转置
        for (int i = 0; i < n; ++i)
            for (int j = i + 1; j < n; ++j)
                swap(matrix[i][j], matrix[j][i]);

        // 每行左右翻转
        for (auto& row : matrix)
            reverse(row.begin(), row.end());
    }
};
```

=== 逆时针旋转 90°

```cpp
class Solution {
public:
    void rotateCounterClockwise(
        vector<vector<int>>& matrix) {
        int n = matrix.size();

        // 1. 转置矩阵
        for (int i = 0; i < n; ++i) {
            for (int j = i + 1; j < n; ++j) {
                swap(matrix[i][j], matrix[j][i]);
            }
        }

        // 2. 垂直翻转（上下互换）
        for (int i = 0; i < n / 2; ++i) {
            swap(matrix[i], matrix[n - 1 - i]);
        }
    }
};
```

== 面试进阶：$O(1)$ 空间，一次遍历（四角交换法）

如果面试官要求*不能分两步走*，必须一次性遍历完成交换，可以使用*分层四角交换法*。

*核心思想*：从外向内，一层一层处理。每次同时交换四个对应位置的元素。

*顺时针旋转的四个角坐标关系*：假设当前上边界为 `top`，左边界为 `left`，偏移量为 `offset`（$0 <= "offset" < "right" - "left"$）：

+ `top`（上）→ `right`（右）
+ `right`（右）→ `bottom`（下）
+ `bottom`（下）→ `left`（左）
+ `left`（左）→ `top`（上）

*代码实现*：

```cpp
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();
        // 层数
        for (int i = 0; i < n / 2; ++i) {
            // 每层的偏移量
            for (int j = i; j < n - 1 - i; ++j) {
                // 保存上边
                int temp = matrix[i][j];
                // 左边给上边
                matrix[i][j] = matrix[n - 1 - j][i];
                // 下边给左边
                matrix[n - 1 - j][i] =
                    matrix[n - 1 - i][n - 1 - j];
                // 右边给下边
                matrix[n - 1 - i][n - 1 - j] =
                    matrix[j][n - 1 - i];
                // 上边给右边
                matrix[j][n - 1 - i] = temp;
            }
        }
    }
};
```

== 考场防忘小技巧：角点代入法

如果在考场上突然忘了坐标公式，*不要慌*，找四个角的坐标代入验证。

以*顺时针 90°* 为例，代入角点坐标：

+ 原来的*左上角* `(0, 0)`，旋转后应该去*右上角* `(0, n-1)`。
+ 原来的*右上角* `(0, n-1)`，旋转后应该去*右下角* `(n-1, n-1)`。
+ 观察规律：行 `i` 变成了列（或列变成了行），并且发生了倒置（`n-1` 减去原坐标）。

*推导步骤*：

+ 原坐标 `(0, j)`（第一行）→ 变成 `(j, n-1)`（最后一列）。得出：*新行 = 原列 `j`*，*新列 = `n-1-原行 i`*。
+ 所以原坐标 `(i, j)` 顺时针转 90° 后变为 *`(j, n-1-i)`*。公式瞬间推导出来！

== 总结

日常刷题直接背*“转置 + 翻转”*法，代码短且不易错；遇到特殊要求（如旋转其他度数、纯数学推导）时，使用*坐标映射公式*；面试高级岗位时，提一嘴*四角交换法*展示基本功。
