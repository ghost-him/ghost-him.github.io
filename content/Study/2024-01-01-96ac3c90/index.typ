#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 183. 望远镜中最高的海拔")

题目：科技馆内有一台虚拟观景望远镜，它可以用来观测特定纬度地区的地形情况。该纬度的海拔数据记于数组~`heights`~，其中~`heights[i]`~表示对应位置的海拔高度。请找出并返回望远镜视野范围~`limit`~内，可以观测到的最高海拔值。

来源：#link("https://leetcode.cn/problems/hua-dong-chuang-kou-de-zui-da-zhi-lcof/description/")[力扣（LeetCode）]

= 题目代码 ：
```cpp
class Solution {
public:
    vector<int> maxAltitude(vector<int>& heights, int limit) {
        vector<int> res;
        deque<int> q;
        int r = 0;
        for (r = 0; r < heights.size(); r ++) {
            if (r - q.front() + 1 > limit && q.size()) q.pop_front();
            while(q.size() && heights[q.back()] <= heights[r]) q.pop_back();
            q.push_back(r);
            if (r >= limit - 1) res.push_back(heights[q.front()]);
        }
        return res;
    }
};
```

时间与空间：20ms 与 16.22MB

= 题解
一个标准的滑动窗口的模板题。使用单调队列优化，时间复杂度为 `O(n)`。

相关链接：#link("/Study/2024-01-01-d1f6f6b2/")[单调队列优化的滑动窗口的原理]
