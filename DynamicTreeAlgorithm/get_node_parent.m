function [parent] = get_node_parent(node, tree)
%GET_NODE_PARENT 
    
    isLeftChild= tree(:,1) == node;
    isRightChild= tree(:,2) == node;
    
    if sum(isLeftChild) == 1
        parent = tree(isLeftChild, 3);
    else if sum(isRightChild) == 1
        parent = tree(isRightChild, 3);
    else
        treeSize = size(tree);
        parent = tree(treeSize(1), treeSize(2));
    % Get the indices of the left and right children of the node from the
    % corresponding columns of the linkage matrix
    end
end


