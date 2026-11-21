#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 160. 数据流中的中位数")

= 题目描述
#strong[中位数]~是有序整数列表中的中间值。如果列表的大小是偶数，则没有中间值，中位数是两个中间值的平均值。

例如， \
`[2,3,4]`~的中位数是~`3` \
`[2,3]`~的中位数是~`(2 + 3) / 2 = 2.5` \
设计一个支持以下两种操作的数据结构：

- `void addNum(int num)`~- 从数据流中添加一个整数到数据结构中。
- `double findMedian()`~- 返回目前所有元素的中位数。

题目来源：#link("https://leetcode.cn/problems/shu-ju-liu-zhong-de-zhong-wei-shu-lcof/")[力扣]

= 题解
代码：

```cpp
class MedianFinder {
public:
    /** initialize your data structure here. */
    std::vector<int> a;
    MedianFinder() {
    }

    void addNum(int num) {
        a.push_back(num);
        for (int i = a.size() - 1; i >0; i --) {
            if (a[i] > a[i - 1]) {
                swap(a[i], a[i - 1]);
            }
        }
    }
    double findMedian() {
        if (a.size() % 2) {
            // 奇数
            return a[a.size() / 2];
        } else {
            // 偶数
            int num1 = a.size() / 2;
            int num2 = (a.size() - 1) / 2;
            return (double)(a[num1] + a[num2]) / 2;
        }
    }
};
/**
 * Your MedianFinder object will be instantiated and called as such:
 * MedianFinder* obj = new MedianFinder();
 * obj->addNum(num);
 * double param_2 = obj->findMedian();
 */
```

用到了插入排序的思想：将一个元素插入到一个有序数组的时间复杂度为 `O(n)`，则总时间复杂度为 `O(n^2)`

== 思路 2
```cpp
class MedianFinder {
public:
    /** initialize your data structure here. */
    priority_queue<int> left;
    priority_queue<int, vector<int>, greater<int>> right;
    MedianFinder() {
  
    }
    void addNum(int num) {
       if (left.size() != right.size()) {
           left.push(num);
           right.push(left.top());
           left.pop();
       } else {
           right.push(num);
           left.push(right.top());
           right.pop();
       }
  
    }
    double findMedian() {
        if (left.size() == right.size()) {
            return (double) (left.top() + right.top()) / 2;
        } else {
            return (double) left.top();
        }
    }
};
  
/**
 * Your MedianFinder object will be instantiated and called as such:
 * MedianFinder* obj = new MedianFinder();
 * obj->addNum(num);
 * double param_2 = obj->findMedian();
 */
```

思路来源：#link("https://leetcode.cn/problems/shu-ju-liu-zhong-de-zhong-wei-shu-lcof/solutions/227309/mian-shi-ti-41-shu-ju-liu-zhong-de-zhong-wei-shu-y/")[力扣]
