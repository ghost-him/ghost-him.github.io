#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 067. 数组中两个数的最大异或值")

= 题目描述
给定一个整数数组~`nums`~，返回~`nums[i] XOR nums[j]`~的最大运算结果，其中~`0 ≤ i ≤ j < n`~。

题目来源：#link("https://leetcode.cn/problems/ms70jA/description/")[力扣（LeetCode）]

= 题解
代码：

```cpp
class Solution {
public:
    #define N 400010
    int cnt[N] = {0};
    int tr[N][2] = {0};
    int idx = 0;
    void add(int x) {
        int p = 0;
        // 从大往小遍历：优先匹配高有效位的数
        for (int i = 31; i >=0 ;i --) {
            // 获取当前的位：[0 | 1]
            int u = x >> i & 1; 
            // 将这个结点添加到p结点下
            if (!tr[p][u]) tr[p][u] = ++ idx; // 如果没有u子结点，则添加一个子结点
            // 将p指针移动到这个子结点下，然后遍历下一位
            p = tr[p][u];
            // 标记一下：有一个数可以到这个结点。
            cnt[p] ++;
        }
    }
    int query(int x) {
        // 返回的是与x异或后的最大值
        int res = 0; // 答案，与x异或后的最大值
        int p = 0;   // 根结点的指针
        // 从大往小的匹配，优先匹配高有较位
        for (int i = 31; i >=0; i --) {
            // 获取当前的位
            int u = x >> i & 1;
            /*
                如果两个位异或，则相异时，结点才为1。结果的1越多，值越大。
                0 ^ 1 = 1
                所以如果当前的x为001，且p指向1时，则当前期望的位应该是0
                001 
                11x ^
                -----
                11?
                如果当x为0时，?为1，因此结果会更大。同时，如果p为0时，则期望的是1。所以如果p是u，则期望的是!u。
            */
            // u为p所期望的数
            u = !u;
            // 检查期望的值是否存在
            if (cnt[tr[p][u]] == 0) res = res * 2 + 0, p = tr[p][!u]; // 如果不存在，则异或后的结果为0，将0添加到返回值中，将p移动到其子结点。p所指针的结点一定要存在。tr[p][!u]不存在，则tr[p][u]一定存在：已经将x存入到了树中，所以tr[p][u]一定存在。
            else res = res * 2 + 1, p = tr[p][u]; // 如果存在，则异或后的结果为1，将1添加到返回值中，将p移到期望的结点中。
        }
        return res;
    }
  
    int findMaximumXOR(vector<int>& nums) {
        int res = -2e9;
        for (auto &i : nums) {
            add(i);
        }
        for (auto &i : nums) {
            res = max(res, query(i));
        }
        return res;
    }
};
```

字典树的模板题，详细见：#link("/Study/2024-01-06-528204e5/")[链接]
