% Function to get the children of a node given a dendrogram tree

% Inputs:
% - node: index of the node to get the children for
% - tree: (indexed) linkage matrix obtained from clustering after applying
%         the function 'linkage_to_tree'

% Outputs:
% - childL: index of the left child of the node
% - childR: index of the right child of the node

function [childL, childR] = get_children(node, tree)
    % Find the row in the linkage matrix corresponding to the given node
    idx = tree(:, 3) == node;
    
    % Get the indices of the left and right children of the node from the
    % corresponding columns of the linkage matrix
    childL = tree(idx, 1);
    childR = tree(idx, 2);
end
