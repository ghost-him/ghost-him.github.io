#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 153. 二叉树中和为目标值的路径")

= 题目描述
给你二叉树的根节点~`root`~和一个整数目标和~`targetSum`~，找出所有~#strong[从根节点到叶子节点]~路径总和等于给定目标和的路径。

#strong[叶子节点]~是指没有子节点的节点。

题目来源：#link("https://leetcode.cn/problems/er-cha-shu-zhong-he-wei-mou-yi-zhi-de-lu-jing-lcof/description/")[力扣]

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
vector<vector<int>> ans;
int tar;
  
class Solution {
public:
    void dfs(TreeNode* u, vector<int>& path, int val) {
        if (u == nullptr)
            return ;
  
        path.push_back(u->val);
        val += u->val;
  
        if (val == tar && u->left == nullptr && u->right == nullptr) {
            ans.push_back(path);
            path.pop_back();
            return ;
        }
        dfs(u->left, path, val);
        dfs(u->right, path, val);
        path.pop_back();
    }
  
    vector<vector<int>> pathTarget(TreeNode* root, int target) {
        tar = target;
        ans.clear();
        vector<int> ret;
        dfs(root, ret, 0);
        return ans;
    }
};
```
