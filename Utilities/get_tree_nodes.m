function [nodes] = get_tree_nodes(root, tree)
%GET_TREE_NODES given the tree root, return all nodes componing the tree
    
    nodes = [];
    
    [childL, childR] = get_children(root, tree);
    if ~isempty(childL)
        nodes = [childL get_tree_nodes(childL, tree)];
    end
    
    if ~isempty(childR)
        nodes = [nodes childR get_tree_nodes(childR, tree)];
    end
    
end

