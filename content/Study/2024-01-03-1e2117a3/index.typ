#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 039. 柱状图中最大的矩形")

题目：给定非负整数数组~`heights`~，数组中的数字用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为~`1`~。

求在该柱状图中，能够勾勒出来的矩形的最大面积。

题目来源：#link("https://leetcode.cn/problems/largest-rectangle-in-histogram/")[力扣（LeetCode）]

= 代码
```cpp
class Solution {
public:
    #define N 100010
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
};
```

= 题解
考察点：单调栈的应用。基本的解题思路：以第 i 个柱子为基准，找到左边第一个比当前小的柱子的下标 a，找到右边比当前小的柱子的下标 b。然后当前的面积则为 `(b - a + 1) * heights[i]`。

使用单调栈可以快速的找到左边或右边比当前小的柱子。单调栈维护的是比当前柱子小的柱子的下标。
