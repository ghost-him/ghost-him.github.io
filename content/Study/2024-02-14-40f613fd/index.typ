#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 112. 矩阵中的最长递增路径")

= 题目
给定一个~`m x n`~整数矩阵~`matrix`~，找出其中~#strong[最长递增路径]~的长度。

对于每个单元格，你可以往上，下，左，右四个方向移动。~#strong[不能]~在~#strong[对角线]~方向上移动或移动到~#strong[边界外]（即不允许环绕）。

题目来源：#link("https://leetcode.cn/problems/fpTFWP/description/")[力扣]

= 题解
```cpp
typedef pair<int, int> PII;
  
const int N = 210;
vector<vector<int>> g;
int st[N][N];
  
int n, m;
int dx[4] = {0, 1, 0, -1};
int dy[4] = {1, 0, -1, 0};
  
int ans = 1;
  
class Solution {
public:
  
    void dfs(int sx, int sy) {
        cout << sx << " " << sy << endl;
        if (st[sx][sy]) return ;
        st[sx][sy] = 1;
        for (int i = 0; i < 4; i ++) {
            int nx = sx + dx[i], ny = sy + dy[i];
            if (nx < 0 || nx >= n || ny < 0 || ny >= m) continue;
  
            if (g[nx][ny] > g[sx][sy]) {
                // 只有当满足条件时，才可以进行遍历，不然会发生遍历不完全的情况
                if (st[nx][ny] == 0) {
                    dfs(nx, ny);
                }
                st[sx][sy] = max(st[sx][sy], st[nx][ny] + 1);
            }
        }
    }
    int longestIncreasingPath(vector<vector<int>>& matrix) {
        g = matrix;
        n = matrix.size(), m = matrix[0].size();
        ans = 1;
        memset(st, 0, sizeof st);
        for (int i = 0; i < matrix.size(); i ++) {
            for (int j = 0; j < matrix[0].size(); j ++) {
                dfs(i, j);
                ans = max(ans, st[i][j]);
            }
        }
        return ans;
    }
  
};
```
