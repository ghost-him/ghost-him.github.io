#import "../../index.typ": template, tufted
#show: template.with(title: "栈的应用（计算器）")

本文介绍了栈的三种算法，分别是#strong[括号匹配算法]，#strong[中缀表达式转后缀表达式算法]和#strong[后缀表达式计算算法]。同时，还写了一个计算器的例子将这三种算法结合起来。

= 括号匹配算法1. 初始化一个空栈，顺序读入括号
#block[
#set enum(numbering: "1.", start: 2)
+ 若是右括号则与栈顶元素进行匹配（若匹配，则弹出栈顶元素并进行下一元素；若不匹配，则该序列不合法）
+ 若是左括号，则压入栈中
+ 若全部元素遍历完毕，栈中仍然存在元素，则该序列不合法
]

= 中缀表达式转后缀表达式算法
+ 从左到右遍历中缀表达式的每个数字和符号
  + 如果检测到数字，则直接加入到后缀表达式中
  + 如果检测到运算符时：
    + 若为 `(`，入栈
    + 若为 `)`，则依次将栈中的运算符加入后缀表达式，直到出现 `(`，并从栈中删除 `(`
    + 若为 `+`，`-`，`*`，`/`, 则一直将栈顶元素加入到后缀表达式中，并弹出。直到栈顶元素的优先级低于自身或遇到 `(`。
+ 一直到最终输出后缀表达式为止。

= 后缀表达式计算算法
+ 建立一个操作数栈 S。
+ 从左到右读表达式，如果读到操作数就将它压入栈 S 中，如果读到运算符，则取出由栈顶向下的 2 项操作数进行运算，再将运算的结果代替原栈顶的 2 项压入栈中

= 计算器例子
该计算器使用 `c++` 语言编写，版本要大于 11 即可编译。可以实现 0-9 以内的#strong[加减乘除]。支持括号。可以判断符号优先级。

由于只是为了练习一下栈的算法，所以没有过多的错误处理和更加优秀的程序结构。

大体思路：

+ 读入一个要计算的表达式
+ 判断括号是否匹配，如果不匹配则返回（括号匹配算法）
+ 将中缀表达式转换为后缀表达式（中缀表达式转后缀表达式算法）
+ 计算后缀表达式的值（后缀表达式计算算法）
+ 输出后缀表达式的值，跳转到步骤 1

== 代码实现
```cpp
#include <iostream>
#include <algorithm>
#include <cstring>
#include <stack>
using namespace std;

// 获取一个符号的优先级

int level(char t)
{
    if (t >= '0' && t <= '9')
    {
        return 0;
    }
    else if (t == '+' || t == '-')
    {
        return 1;
    }
    else if (t == '*' || t == '/')
    {
        return 2;
    }
    else if (t == '(')
    {
        return 3;
    }
    return 4;
}
// 判断当前的括号是否匹配
bool check(string &str)
{
    stack<char> s;
    for (auto &i : str)
    {
        if (i == '(')
        {
            s.push(i);
        }
        else if (i == ')')
        {
            // ')' 多了
            if (s.empty())
            {
                return false;
            }
            s.pop();
        }
    }
    // 如果运行完了以后，还是有没有匹配完的括号，说明不合法 '(' 多了
    if (!s.empty())
    {
        return false;
    }
    return true;
}
// 中缀转后缀
string convert(string &str)
{
    //  返回的值
    string ans;
    // 栈
    stack<char> s;
    for (auto &i : str)
    {
        switch (level(i))
        {
        case 0:
        {
            // 如果是数字
            ans.push_back(i);
            break;
        }
        case 1:
        {
            // 如果是加减
            while (!s.empty() && level(s.top()) >= 1 && level(s.top()) != 3)
            {
                ans.push_back(s.top());
                s.pop();
            }
            s.push(i);
            break;
        }
        case 2:
        {
            // 如果是乘除，算法和加减一样
            while (!s.empty() && level(s.top()) >= 2 && level(s.top()) != 3)
            {
                ans.push_back(s.top());
                s.pop();
            }
            s.push(i);
            break;
        }
        case 3:
        {
            // 如果是'('
            s.push(i);
            break;
        }
        case 4:
        {
            // 如果是')'
            while (!s.empty() && level(s.top()) != 3)
            {
                ans.push_back(s.top());
                s.pop();
            }
            // 当前的循环到'('为止，此时，'('还会在栈中，在要弹出
            s.pop();
            break;
        }
        }
    }
    while (!s.empty())
    {
        ans.push_back(s.top());
        s.pop();
    }
    return ans;
}
// 计算表达式
double compute(string &str)
{
    // 计算后缀表达式
    string con = convert(str);
    // 开两个栈，一个存放符号，一个存放数字
    stack<char> sc;   // stack_char
    stack<double> si; // stack_int
    // 遍历后缀表达式
    for (auto &i : con)
    {
        // 如果是一个数字
        if (level(i) == 0)
        {
            si.push(i - '0');
        }
        else
        {
            // 如果是一个符号
            double b = si.top();
            si.pop();
            double a = si.top();
            si.pop();
            double ans;
            // 执行相应的运算
            if (i == '+')
                ans = a + b;
            else if (i == '-')
                ans = a - b;
            else if (i == '*')
                ans = a * b;
            else
                ans = a / b;
            // 将结果压入栈中
            si.push(ans);
        }
    }
    // 运行结束以后，就只剩下一个结果
    return si.top();
}
int main()
{
    while (1)
    {
        string str;
        cin >> str;
        // 检查是否括号匹配
        if (!check(str))
        {
            cout << "当前的括号不匹配" << endl;
            continue;
        }
        // 计算结果
        cout << compute(str) << endl;
    }
    return 0;
}
```
