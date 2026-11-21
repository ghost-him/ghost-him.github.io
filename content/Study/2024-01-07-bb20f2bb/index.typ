#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 105. 岛屿的最大面积")

= 题目描述
给定一个由~`0`~和~`1`~组成的非空二维数组~`grid`~，用来表示海洋岛屿地图。

一个~#strong[岛屿]~是由一些相邻的~`1`~(代表土地) 构成的组合，这里的「相邻」要求两个~`1`~必须在水平或者竖直方向上相邻。你可以假设~`grid`~的四个边缘都被~`0`（代表水）包围着。

找到给定的二维数组中最大的岛屿面积。如果没有岛屿，则返回面积为~`0`~。

题目来源：#link("https://leetcode.cn/problems/ZL6zAn/description/")[力扣]

= 题解
代码

```cpp
class Solution {
public:
#define N 60
    int res = 0;
    // st[i][j]：(i, j)这个点是否被遍历过
    bool st[N][N] = {0};
    int n, m; // 行数与列数
    vector<vector<int>> g;
  
    int dx[4] = {0, 1, 0, -1};
    int dy[4] = {1, 0, -1, 0};
    int maxAreaOfIsland(vector<vector<int>>& grid) {
        n = grid.size();
        m = grid[0].size();
        g = grid;
  
        for (int i = 0; i < n; i ++) {
            for (int j = 0; j < m; j ++) {
                // 如果当前的是一个没有被遍历过的岛，则遍历这个岛
                if (grid[i][j] == 1 && st[i][j] == false) {
                    bfs(i, j);
                }
            }
        }
        return res;
    }
  
    void bfs(int a, int b) {
        // 定义一个队列来广度遍历 
        queue<pair<int, int>> q;
        q.push({a, b});
        int s = 0; // 当前岛的面积
        // 只要队列中还有数字
        while (q.size()) {
            // 拿出第一个元素
            pair<int, int> temp = q.front();
            q.pop();
            // 面积+1
            s ++;
            // 拿出x, y
            int x = temp.first, y = temp.second;
            // 设置当前的点已经遍历过
            st[x][y] = true;
            // 遍历四个方向
            for (int i = 0; i < 4; i ++) {
                // 目标点
                int nx = x + dx[i], ny = y + dy[i];
                // 判断当前的点是否合法
                if (nx < 0 || nx >= n || ny < 0 || ny >= m) continue;
                // 如果当前的点是一个没有遍历过的点
                if (g[nx][ny] == 0 || st[nx][ny] == true) continue;
                // 设置当前的点已经遍历过
                st[nx][ny] = true;
                // 加到队列中
                q.push({nx, ny});
            }
        }
        // 更新答案
        res = max(res, s);
    }
};

```

广度遍历的一个模板题
