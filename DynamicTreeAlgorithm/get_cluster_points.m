% This function returns the data points from a cluster given their indices
% in the original dataset X
%
% Inputs:
% - X: original dataset, a matrix of size (d x n) where d is the number of 
%      dimensions and n is the number of data points
% - idxPoints: a vector of size (m x 1) containing the indices of the data
%              points in the cluster
%
% Outputs:
% - P: a matrix of size (d x m) containing the data points in the cluster

function P = get_cluster_points(X, idxPoints)
    % Extract the columns of X corresponding to the indices in idxPoints
    P = X(:, idxPoints);
end


