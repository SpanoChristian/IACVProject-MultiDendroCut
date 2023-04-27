function [clusterScore] = computeGricCluster(X, tree, clusterIndex)
%COMPUTEGRICCLUSTER Summary of this function goes here
%   Detailed explanation goes here

    clusterPoints = X(:, getLeavesFromNode(clusterIndex, tree));
    getGricScore(clusterPoints, size(X,2));

end

