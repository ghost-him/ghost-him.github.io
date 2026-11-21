#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 044. 在每个树行中找最大值")

= 题目描述
给定一棵二叉树的根节点~`root`~，请找出该二叉树中每一层的最大值。

题目来源：#link("https://leetcode.cn/problems/hPov7L/description/")[力扣（LeetCode）]

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
    vector<int> res;  // 答案，res[i]表示第i层的最大值。根结点为第0层。
    vector<int> largestValues(TreeNode* root) {
        get(root, 0);
        return res;
    }
    void get(TreeNode* u, int depth) {
        if (u == nullptr)
            return ;
        // 如果res数组的大小小于 depth，则要扩充长度，否则直接访问时会报错。由于结点值的最小值为-2^31，所以要用INT_MIN来初始化
        if (res.size() <= depth)
            res.resize(depth + 1, INT_MIN);
        res[depth] = max(u->val, res[depth]);
        get(u->left, depth + 1);
        get(u->right, depth + 1);
    }
};
```

`void get(TreeNode *u, int depth)`：传入的是第 `depth` 层的结点 `u`。然后用 `u` 的值更新第 `depth` 层的最大值。
