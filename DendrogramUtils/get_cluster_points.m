% Function to get the points belonging to a cluster

% Inputs:
%   - C: index of the cluster to get points for
%   - X: data points in the dataset
%   - tree: linkage matrix obtained from J-Linkage (or T-Linkage) after
%           applying the function "linkage_to_tree"
    
% Output:
%   - P: vector of indices of data points belonging to the cluster

function P = get_cluster_points(C, X, tree)
    % Initialize the vector of cluster points to an empty array
    P = [];
    
    % Get the number of data points in the dataset
    n = size(X, 2);
    
    % Get the indices of the children of the cluster
    [childL, childR] = get_children(C, tree);
    
    % If both children are data points, add them to the cluster points
    if childL <= n && childR <= n
        P = [P childL];
        P = [P childR];
        
    % If one child is a data point and the other is a cluster, add the
    % data point and recursively get the cluster points for the other child
    elseif childL <= n && childR > n
        P = [P childL];
        P = [P get_cluster_points(childR, X, tree)];
    elseif childL > n && childR <= n
        P = [P childR];
        P = [P get_cluster_points(childL, X, tree)];
        
    % If both children are clusters, recursively get the cluster points
    % for each child and add them to the cluster points
    else
        P = [P get_cluster_points(childL, X, tree)];
        P = [P get_cluster_points(childR, X, tree)];
    end
end
