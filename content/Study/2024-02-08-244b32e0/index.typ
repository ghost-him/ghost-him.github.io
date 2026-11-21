#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 012. 寻找数组的中心下标")

= 题目描述
给你一个整数数组~`nums`~，请计算数组的~#strong[中心下标]~。

数组~#strong[中心下标]~是数组的一个下标，其左侧所有元素相加的和等于右侧所有元素相加的和。

如果中心下标位于数组最左端，那么左侧数之和视为~`0`~，因为在下标的左侧不存在元素。这一点对于中心下标位于数组最右端同样适用。

如果数组有多个中心下标，应该返回~#strong[最靠近左边]~的那一个。如果数组不存在中心下标，返回~`-1`~。

题目来源：#link("https://leetcode.cn/problems/tvdfij/")[力扣]

= 题解
```cpp

class Solution {
public:
    int pivotIndex(vector<int>& nums) {
        int n = nums.size();
        vector<int> sum(n + 1, 0);
        for (int i = 0; i < nums.size(); i++) {
            sum[i + 1] = nums[i];
        }
  
        for (int i = 1; i <= n ; i ++) {
            sum[i] += sum[i - 1];
        }
        int res = -1;
        for (int i = 1; i <= n; i ++) {
            if (sum[i - 1] == sum[n] - sum[i]) {
                res = i;
                break;
            }
        }
        return max(res - 1, -1);
    }
};
```

前缀和的模版题
