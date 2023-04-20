% Function to get the points INDICES belonging to a cluster

% Inputs:
%   - C: index of the cluster to get points for
%   - X: data points in the dataset
%   - tree: linkage matrix obtained from J-Linkage (or T-Linkage) after
%           applying the function "linkage_to_tree"
    
% Output:
%   - idxP: vector of indices of data points belonging to the cluster

function idxP = get_cluster_idxPoints(C, X, tree)
    % Initialize the vector of cluster points to an empty array
    idxP = [];
    
    % Get the number of data points in the dataset
    n = size(X, 2);
    
    % Check if the given cluster is a leaf
    if ~isleaf(C, X)
        % If it is NOT a leaf then get the children that will be expanded
        % recursively
        [childL, childR] = get_children(C, tree);
   
        % If both children are data points, add them to the cluster points
        if childL <= n && childR <= n
            idxP = [idxP childL];
            idxP = [idxP childR];
        % If one child is a data point and the other is a cluster, add the
        % data point and recursively get the cluster points for the other child
        elseif childL <= n && childR > n
            idxP = [idxP childL];
            idxP = [idxP get_cluster_idxPoints(childR, X, tree)];
        elseif childL > n && childR <= n
            idxP = [idxP childR];
            idxP = [idxP get_cluster_idxPoints(childL, X, tree)];

        % If both children are clusters, recursively get the cluster points
        % for each child and add them to the cluster points
        else
            idxP = [idxP get_cluster_idxPoints(childL, X, tree)];
            idxP = [idxP get_cluster_idxPoints(childR, X, tree)];
        end
    else % If the cluster is a leaf, simply add it as a point
        idxP = [idxP C];
    end
    
end
