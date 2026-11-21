#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 059. 数据流中的第 K 大元素")

= 题目描述
设计一个找到数据流中第~`k`~大元素的类（class）。注意是排序后的第~`k`~大元素，不是第~`k`~个不同的元素。

请实现~`KthLargest`~类：

- `KthLargest(int k, int[] nums)`~使用整数~`k`~和整数流~`nums`~初始化对象。
- `int add(int val)`~将~`val`~插入数据流~`nums`~后，返回当前数据流中第~`k`~大的元素。

#link("https://leetcode.cn/problems/jBjn9C/description/")[题目链接]

= 题解
```cpp

class KthLargest {
public:
    KthLargest(int k, vector<int>& nums) {
        size = k;
        for (auto & i : nums) {
            add(i);
        }
    }
    int add(int val) {
        if (heap.size() < size) {
            heap.push(val);
        } else if (val > heap.top()){
            heap.pop();
            heap.push(val);
        }
        return heap.top();
    }
private:
    int size;
    priority_queue<int, vector<int>, greater<int>> heap;
};
/**
 * Your KthLargest object will be instantiated and called as such:
 * KthLargest* obj = new KthLargest(k, nums);
 * int param_1 = obj->add(val);
 */
```

第 k 大元素的理解： 第 1 大的元素---数组中最大的元素，第 2 大的元素：数组中次大的元素… 第 k 大的元素：数组中第 k 大的元素。可以发现如果想要知道第 k 大的元素，我们只需要知道数组中最大的那 k 个元素即可。那么我们可以用一个小根堆，当堆中存了 k 个元素，那么堆顶的元素就是这 k 个元素中最小的那一个。这就是这个题目的解题思路。
