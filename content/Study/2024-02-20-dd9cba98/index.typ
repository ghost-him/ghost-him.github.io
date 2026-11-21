#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 015. 找到字符串中所有字母异位词")

= 题目描述
给定两个字符串~`s`~和~`p`，找到~`s`~中所有~`p`~的~#strong[变位词]~的子串，返回这些子串的起始索引。不考虑答案输出的顺序。

#strong[变位词]~指字母相同，但排列不同的字符串。

题目来源：#link("https://leetcode.cn/problems/VabMRr/description/")[力扣]

= 题解
```cpp
class Solution {
public:
    bool check() {
        for (int i = 0; i < 26; i ++) {
            if (st[i])
                return false;
        }
        return true;
    }
  
    int st[26];
    vector<int> findAnagrams(string s, string p) {
        vector<int> res;
        for (auto& i : p) {
            st[i - 'a'] ++;
        }
  
        for (int i = 0; i < s.size(); i ++) {
            st[s[i] - 'a'] --;
            if (i >= p.size()) {
                st[s[i - p.size()] - 'a']++;
            }
            if (check())
                res.push_back(i - p.size() + 1);
        }
        return res;
    }
};
```

根据题目的数据范围可知，这个题目的最坏时间复杂度要控制在 $O \( n l o g n \)$ 内。

由于匹配时无需关心内部的字母的顺序，所以我开了一个数组，表示每个字母应该出现的次数，长度为 26（一共有 26 个字母）。先用 p 字符串初始化这个数组。当数组中所有的元素全为 0 时，表示匹配了。

该算法的时间复杂度为 `O(n)`
