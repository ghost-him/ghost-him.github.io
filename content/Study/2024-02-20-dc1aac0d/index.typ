#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 174. 寻找二叉搜索树中的目标节点")

= 题目描述
某公司组织架构以二叉搜索树形式记录，节点值为处于该职位的员工编号。请返回第~`cnt`~大的员工编号。

题目来源：#link("https://leetcode.cn/problems/er-cha-sou-suo-shu-de-di-kda-jie-dian-lcof/description/")[力扣]

= 题解
```cpp
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    void dfs(TreeNode* u, vector<int>& p){
        if (u) {
            p.push_back(u->val);
            dfs(u->left, p);
            dfs(u->right, p);
        }
    }
    int findTargetNode(TreeNode* root, int cnt) {
        vector<int> ans;
        dfs(root, ans);
        sort(ans.begin(), ans.end());
        return ans[ans.size() - cnt];
    }
};
```
