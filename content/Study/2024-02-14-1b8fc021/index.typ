#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 053. 二叉搜索树中的中序后继")

= 题目
给定一棵二叉搜索树和其中的一个节点~`p`~，找到该节点在树中的中序后继。如果节点没有中序后继，请返回~`null`~。

节点~`p`~的后继是值比~`p.val`~大的节点中键值最小的节点，即按中序遍历的顺序节点~`p`~的下一个节点。

题目来源：#link("https://leetcode.cn/problems/P5rCT8/description/")[加扣]

= 题解
```cpp
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */

class Solution {
public:
    vector<TreeNode*> store;
    void dfs(TreeNode * u) {
        if (u == nullptr) return;
        dfs(u->left);
        store.push_back(u);
        dfs(u->right);
    }
  
    TreeNode* inorderSuccessor(TreeNode* root, TreeNode* p) {
        dfs(root);
  
        auto i = find(store.begin(), store.end(), p);
        if (i + 1 == store.end()) return nullptr;
        return *(i + 1);
    }
};
```

空间换时间
