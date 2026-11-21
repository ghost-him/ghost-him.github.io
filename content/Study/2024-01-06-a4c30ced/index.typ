#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 076. 数组中的第 K 个最大元素")

= 题目描述
给定整数数组~`nums`~和整数~`k`，请返回数组中第~`k`~个最大的元素。

请注意，你需要找的是数组排序后的第~`k`~个最大的元素，而不是第~`k`~个不同的元素。来源：#link("https://leetcode.cn/problems/xx4gT2/description/")[力扣（LeetCode）]

= 题解
代码

```cpp
class Solution {
public:
    int findKthLargest(vector<int>& nums, int k) {
        sort(nums.begin(), nums.end());
        return nums[nums.size() - k];
    }
};
```

先排个序，求的就是 `nums.size() - k` 位置的数，时间复杂度为 `o(nlogn)`
