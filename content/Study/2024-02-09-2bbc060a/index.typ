#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 070. 有序数组中的单一元素")

= 题目描述
给定一个只包含整数的有序数组~`nums`~，每个元素都会出现两次，唯有一个数只会出现一次，请找出这个唯一的数字。

= 题解
== 法一
```cpp
const int N = 100010;
bool st[N] = {0};
  
class Solution {
public:
    int singleNonDuplicate(vector<int>& nums) {
        for (auto i : nums) {
            st[i] = st[i] ? false : true;
        }
        int res = 0;
        for (int i = 0; i < 1e5; i ++) {
            if (st[i])
                res = i;
        }
        return res;
    }
};
```

由于最大的数就只有 `1e5`，所以可以直接开一个数组来遍历就可以了。时间复杂度：`O(n)`

== 法二
```cpp
  
class Solution {
public:
    int singleNonDuplicate(vector<int>& nums) {
        int l = 0, r = nums.size() - 1;
        while(l < r) {
            int mid = l + r >> 1;
            if (mid % 2) mid --;
            if (nums[mid] == nums[mid + 1]) {
                l = mid + 2;
            } else {
                r = mid;
            }
        }
        return nums[l];
    }
};
```

由于只出现一次的元素所在下标~`x`~的左边有偶数个元素，因此下标~`x`~一定是偶数，可以在偶数下标范围内二分查找。以下的一个例子来看：

`1 1 2 2 3 3 4 5 5`

`l` 指向 0，`r` 指向 9。那么 `mid` 为 4。此时，`nums[mid] == nums[mid + 1]`。可以得出，mid 前面的所有的数都是成对出现的，所以只需要遍历 `mid + 2` 开始，直到后面的数。此时 `l` 为 6，`r` 为 9，mid 为 7，若 mid 为奇，则要减 1，此时，mid 为 6，而 `nums[mid] != mid[mid + 1]`，所以，可能数只会在 mid 左边，此时，r = mid = 6，`l == r` 退出循环，找到。

时间复杂度：`O(logn)`
