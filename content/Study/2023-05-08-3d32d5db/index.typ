#import "../../index.typ": template, tufted
#show: template.with(title: "C++高精度计算模版")

提供了一些 c++ 的高精度运算模版，可以解决 c++要计算高精度的问题

由于 c++ 没有类似于 java 和 python 等语言的高精度库，所以如果我们要在 c++ 中存放高精度数据，需要我们自己手写一个高精度的算法。我们可以使用 `vector` 库来倒序存放一个数字。即低位在前，高位在后。

= 低精度转高精度
作用：输出转换以后的高精度 限制：输入的数是正数 返回值：转换以后的高精度

```cpp
vector<int> convert(int a) {
    vector<int> c;
    while (a) {
        c.push_back(a % 10);
        a /= 10;
    }
    return c;
}
```

= 字符串转高精度
作用：输出转换以后的高精度 限制：输入的数是正数 返回值：转换以后的高精度

```cpp
vector<int> convert(string a) {
    vector<int> c;
    for (int i = a.size() - 1; i >= 0; i --) {
        c.push_back(a[i] - '0');
    }
    return c;
}
```

= 输出一个高精度
作用：输出高精度 限制：输出的数是正数 返回值：void

```cpp
void print(vector<int> c) {
    for (int i = c.size() - 1; i >= 0; i --) {
        cout << c[i];
    }
    cout << endl;
}
```

= 高精度和高精度的对比
作用：对比两个高精度 限制：a 和 b 都是正数 返回值：如果 a 比 b 大，那么返回 1，如果 a 比 b 小返回-1，如果 a 和 b 一样大，则返回 0。

```cpp
int compare(vector<int> & a, vector<int> & b) {
    if (a.size() < b.size()) return -1;
    if (a.size() > b.size()) return 1;
    for (int i = a.size() - 1; i >= 0; i --) {
        if (a[i] > b[i]) return 1;
        else if (a[i] < b[i]) return -1;
    }
    return 0;
} 
```

= 高精度加高精度
作用：将两个高精度相加 限制：两个数都是正数 返回值：相加以后的高精度

```cpp
vector<int> add(vector<int> & a, vector<int> & b) {
    vector<int> c;
    for (int i = 0, t = 0; i < a.size() || i < b.size() || t; i ++) {
        if (i < a.size()) t += a[i];
        if (i < b.size()) t += b[i];
        c.push_back(t % 10);
        t /= 10;
    }
    while (c.size() > 1 && c.back() == 0) c.pop_back();
    return c;
}
```

= 高精度减高精度
作用：将两个高精度相减 限制：两个数都是正数，且 a \> b 返回值：相减以后的值

```cpp
vector<int> sub(vector<int> &a ,vector<int> &b) {
    vector<int> c;
    for (int i = 0, t = 0; i < a.size(); i ++) {
        t += a[i];
        if (i < b.size()) t -= b[i];
        c.push_back((t + 10) % 10);
        if (t < 0) t = -1;
        else t = 0;
    }
    while (c.size() > 1 && c.back() == 0) c.pop_back();
    return c;
}
```

= 高精度乘高精度
作用：将两个高精度相乘 限制：两个数都是正数 返回值：两个数相乘以后的高精度

```cpp
vector<int> mul(vector<int> &a, vector<int> &b) {
    vector<int> c(a.size() + b.size());
    for (int i = 0; i < a.size(); i ++) {
        for (int j = 0; j < b.size(); j ++) {
            c[i + j] += a[i] * b[j];
        }
    }
    
    for (int i = 0, t = 0; i < c.size() || t; i ++) {
        t += c[i];
        c[i] = t % 10;
        t /= 10;
    }
    
    while (c.size() > 1 && c.back() == 0) c.pop_back();
    return c;
}
```

= 高精度加低精度
作用：将一个高精度和一个低精度相加 限制：两个数都是正数 返回值：两个数相加以后的高精度

```cpp
vector<int> add(vector<int>& a, int b) {
    vector<int> c;
    for (int i = 0, t = b; i < a.size() || t; i ++) {
        if (i < a.size()) t += a[i];
        c.push_back(t % 10);
        t /= 10;
    }
    return c;
}
```

= 高精度乘低精度
作用：将一个高精度和一个低精度相乘 限制：两个数都是正数 返回值：两个数相乘以后的高精度

```cpp
vector<int> mul(vector<int> &a, int b) {
    vector<int> c;
    for (int i = 0, t = 0; i < a.size() || t; i ++) {
        if (i < a.size()) t += a[i] * b;
        c.push_back(t % 10);
        t /= 10;
    }
    return c;
}
```

= 高精度除低精度
作用：将一个高精度和一个低精度相除，以及求其余数 限制：两个数都是正数 返回值：两个数相除以后的高精度

```cpp
vector<int> div(vector<int> &a, int b, int &r) {
    vector<int> c;
    for (int i = a.size() - 1; i >= 0; i -- ) {
        r = r * 10 + a[i];
        c.push_back(r / b);
        r %= b;
    }
    reverse(c.begin(), c.end());
    while (c.size() > 1 && c.back() == 0) c.pop_back();
    
    return c;
}
```
