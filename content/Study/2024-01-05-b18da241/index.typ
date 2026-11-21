#import "../../index.typ": template, tufted
#show: template.with(title: "LCR 051. 二叉树中的最大路径和")

= 题目描述
#strong[路径]~被定义为一条从树中任意节点出发，沿父节点-子节点连接，达到任意节点的序列。同一个节点在一条路径序列中~#strong[至多出现一次]~。该路径~#strong[至少包含一个]~节点，且不一定经过根节点。

#strong[路径和]~是路径中各节点值的总和。

给定一个二叉树的根节点~`root`~，返回其~#strong[最大路径和]，即所有路径上节点值之和的最大值。

题目来源：来源：#link("https://leetcode.cn/problems/jC7MId/description/")[力扣（LeetCode）]

= 题解
代码

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
    int res = -2e9;
    int maxPathSum(TreeNode* root) {
        dp(root);
        return res;
    }

    int dp(TreeNode * root) {
        if (root == nullptr) return 0;
        int val = root->val;
        int left = max(dp(root->left), 0);// 如果左子树的路径和小于0，则放弃
        int right = max(dp(root->right), 0); // 如果面子树的路径和小于0，则放弃
        res = max(res, left + val + right); // 更新一下答案
        return max(left, right) + val;    // 返回根结点加一个子树的最大值（一个路径是一条线）
    }
};
```

路径和是路径中各节点值的总和。没有要求两端一定是叶子结点!!!

所以就可以将题目变成一个简单的树型 dp。我们可以画图发现，每一个路径一定是有一个最高点，所以我们只要遍历每个最高点对应的路径的路径和，然后取其最大值既可。`int dp(TreeNode * root)` 求的是以 `root` 为根，包含根结点的路径和。
