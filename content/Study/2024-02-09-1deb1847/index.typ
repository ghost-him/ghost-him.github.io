#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 181. 字符串中的单词反转")

= 题目描述
你在与一位习惯从右往左阅读的朋友发消息，他发出的文字顺序都与正常相反但单词内容正确，为了和他顺利交流你决定写一个转换程序，把他所发的消息~`message`~转换为正常语序。

注意：输入字符串~`message`~中可能会存在前导空格、尾随空格或者单词间的多个空格。返回的结果字符串中，单词间应当仅用单个空格分隔，且不包含任何额外的空格。

题目来源：#link("https://leetcode.cn/problems/fan-zhuan-dan-ci-shun-xu-lcof/description/")[力扣]

= 题解
代码

```cpp
class Solution {
public:
    string reverseMessage(string message) {
        vector<string> res;
        string temp;
        bool flag = false;
        for (auto i : message) {
            if (i != ' ') {
                flag = true;
                temp.push_back(i);
            } else {
                if (flag) {
                    res.push_back(temp);
                    temp.clear();
                }
                flag = false;
            }
        }
        if (flag) {
            res.push_back(temp);
        }
        reverse(res.begin(), res.end());
        stringstream ans;
        for (int i = 0; i < res.size(); i++) {
            ans << res[i];
            if (i + 1 != res.size())
                ans << " ";
        }
        return ans.str();
    }
};
```

先从左往加扫描一遍得出所有的单词，然后使用 `reverse` 数组反转一下就可以了
