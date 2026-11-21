#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 041. 数据流中的移动平均值")

= 题目描述
给定一个窗口大小和一个整数数据流，根据该滑动窗口的大小，计算滑动窗口里所有数字的平均值。

实现~`MovingAverage`~类：

- `MovingAverage(int size)`~用窗口大小~`size`~初始化对象。
- `double next(int val)`~成员函数~`next`~每次调用的时候都会往滑动窗口增加一个整数，请计算并返回数据流中最后~`size`~个值的移动平均值，即滑动窗口里所有数字的平均值。

题目来源：#link("https://leetcode.cn/problems/qIsx9U/description/")[力扣]

= 题解
```cpp
class MovingAverage {
public:
    int size;
    deque<int> q;
    double sum;
    /** Initialize your data structure here. */
    MovingAverage(int size) {
        this->size = size;
        sum = 0;
    }
    double next(int val) {
        q.push_back(val);
        sum += val;
        if (q.size() > size) {
            sum -= q.front();
            q.pop_front();
        }
        return sum / q.size();
    }
};
  
/**
 * Your MovingAverage object will be instantiated and called as such:
 * MovingAverage* obj = new MovingAverage(size);
 * double param_1 = obj->next(val);
 */
```
