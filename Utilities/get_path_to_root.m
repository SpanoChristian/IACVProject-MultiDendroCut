function [path] = get_path_to_root(node, tree)
%GET_PATH_TO_ROOT print all other nodes met moving from the
% given node to the tree root (node and root included)
    parent = get_node_parent(node, tree);
    if parent ~= node
        path = [node get_path_to_root(parent, tree)];
    else
        path= [];
    end
end