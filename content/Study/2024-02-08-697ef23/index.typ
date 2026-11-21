#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 005. 最大单词长度乘积")

= 题目描述
给定一个字符串数组~`words`，请计算当两个字符串~`words[i]`~和~`words[j]`~不包含相同字符时，它们长度的乘积的最大值。假设字符串中只包含英语的小写字母。如果没有不包含相同字符的一对字符串，返回 0。

题目来源：#link("https://leetcode.cn/problems/aseY1I/description/")[力扣]

= 题解
```cpp
bool st[1010][26];
class Solution {
public:
    int maxProduct(vector<string>& words) {
        for (int i = 0; i < words.size(); i++) {
            for (auto& j : words[i]) {
                st[i][j - 'a'] = true;
            }
        }
  
        unsigned long res = 0;
        for (int i = 0; i < words.size(); i ++) {
            for (int j = 0; j < i; j ++) {
                bool flag = true;
                for (int k = 0; k < 26; k ++) {
                    if (st[i][k] && st[j][k]) {
                        flag = false;
                        break;
                    }
                }
                if (flag)
                    res = max(res, words[i].size() * words[j].size());
            }
        }
        return res;
    }
};
```

基础题
