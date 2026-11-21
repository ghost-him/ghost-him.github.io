#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 040. 最大矩形")

= 题目描述
给定一个由~`0`~和~`1`~组成的矩阵~`matrix`~，找出只包含~`1`~的最大矩形，并返回其面积。

注意：此题~`matrix`~输入格式为一维~`01`~字符串数组。、

题目来源：#link("https://leetcode.cn/problems/PLYXKQ/description/")[力扣]

= 题解
代码

```cpp
class Solution {
public:
#define N 210
    int left[N], right[N];
    int largestRectangleArea(vector<int>& heights) {
        stack<int> s;
        // 从左往右找到比下标为i的高度还要低的高度的下标
        for (int i = 0; i < heights.size(); ++i) {
            while(s.size() && heights[s.top()] >= heights[i]) {
                s.pop();
            }
            left[i] = (s.empty() ? -1 : s.top());
            s.push(i);
        }

        // 清空栈
        s = stack<int>();
        // 从右往左找到比下标为i的高度还要低的高度的下标
        for (int i = heights.size() - 1; i >= 0; --i) {
            while(s.size() && heights[s.top()] >= heights[i]) {
                s.pop();
            }
            right[i] = (s.empty() ? heights.size() : s.top());
            s.push(i);
        }
        int ans  = -1;
        // 计算以下标为i为最低高度，算出来的最大的面积
        for (int i = 0; i < heights.size(); i ++) {
            ans = max((right[i] - left[i] - 1) * heights[i], ans);
        }
        return ans;
    }
    int maximalRectangle(vector<string>& matrix) {
        // 结果
        int ans = 0;
        // h[i][j]表示，以第i行为底，第j列的高度
        vector<vector<int>> h;
        // 初始化行数
        h.resize(matrix.size());
        for (int i = 0; i < matrix.size(); i ++) {
            // 初始化第i行的列数
            h[i].resize(matrix[0].size());
            for (int j = 0; j < matrix[0].size();j ++) {
                // 如果第i行，第j列是1，则其高度等于这一列的上一行的高度加1
                if (matrix[i][j] == '1') {
                    // 如果是第0行，则直接加0。h[-1][j]会报错
                    int val = i > 0 ? h[i - 1][j] : 0;
                    h[i][j] = val + 1;
                } else {
                    h[i][j] = 0;
                }
            }
            // 更新一下当前的值
            ans = max(ans, largestRectangleArea(h[i]));
        }
        return ans;
    }
};
```

这个题用到了 #link("https://leetcode.cn/problems/0ynMMM/")[LCR 039.~柱状图中最大的矩形]中的代码，可以把这个二维表看成 i 组柱状图。所以只要调用 i 次代码，即可得出答案
