#import "../../index.typ": template, tufted
#show: template.with(title: "剑指 Offer 47. 礼物的最大价值")

题目：在一个 $m * n$ 的棋盘的每一格都放有一个礼物，每个礼物都有一定的价值（价值大于 $0$）。你可以从棋盘的左上角开始拿格子里的礼物，并每次向右或者向下移动一格、直到到达棋盘的右下角。给定一个棋盘及其上面的礼物的价值，请计算你最多能拿到多少价值的礼物？

来源：#link("https://leetcode.cn/problems/li-wu-de-zui-da-jie-zhi-lcof")[力扣（LeetCode）]

#quote(block: true)[
欢迎关注剑指offer补全系列！
]

= 思路
本题可以使用动态规划的思路。通过题目的描述，我们可以知道这是动态规划的一个#strong[模版题目]。所以可以使用动态规划的模版来完成本题。

= 代码
```cpp
class Solution {
public:
    const int N = 210;
    int maxValue(vector<vector<int>>& grid) {
        // 先获得二维数据的长和宽
        int n = grid.size();
        int m = grid[0].size();
        
        int dp[N][N];
        // 从左上的(0, 0) 走到右下的(n - 1, m - 1)
        for (int i = 0; i < n; i ++) {
            for (int j = 0; j < m; j ++ ) {
                int t = 0;
                // 要处理边界的问题
                if (j - 1 >= 0) t = max(t, dp[i][j - 1]);
                if (i - 1 >= 0) t = max(t, dp[i - 1][j]);
                dp[i][j] = t + grid[i][j];
            }
        }
        return dp[n - 1][m - 1];
    }
}
```
