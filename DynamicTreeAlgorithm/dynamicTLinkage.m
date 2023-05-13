function [lblsDynCut, bestLambda1, bestLambda2, bestThreshold, toMergeClusters] = dynamicTLinkage(X, T, G, labelsTLinkage, ...
    epsilon, isMergeableGricModel, clusterThreshold)
%DYNAMICTLINKAGE Summary of this function goes here
%   Detailed explanation goes here

% Input
%   X: points to clusterize
%   T: matrix provided by T-Linkage
%   G: ground truth (regarding labels), needed only now for testing. Will
%   be removed
%   labelsTLinkage: labels assigned by T-Linkage, needed only now for testing. Will
%   be removed % TODO why is it needed
%   epsilon: maximum distance between points/cluster (not necessarily
%   euclidean)
%   isMergeableGricModel: says if two clusters should be merged
%   clusterThreshold: minimum number of point needed to create a threshold
%   % TODO: va usato qui? (Sì perché almeno anche questa parte dell'algo
%   non crea cluster che non sopravviverebbero alle modifiche future

% Output
%   lblsDynCut: vector assigning a label to each point

    tree = linkage_to_tree(T);
    root = tree(end, 3);
    
    lambdaRange = 0:5:60;
    [bestLambda1, bestLambda2, bestThreshold] = computeBestParams(root, X, tree, G, labelsTLinkage, lambdaRange, ...
        isMergeableGricModel, epsilon);
    
    %%
    [~, ~, ~, ~, toMergeClusters] = exploreDFS(root, X, tree, bestLambda1, bestLambda2, epsilon, ...
        isMergeableGricModel, false);
    toMergeClustersOrdered = sort(toMergeClusters, "descend") %debug purpose
    lblsDynCut = labelsAfterDynCut(X, tree, toMergeClusters, bestThreshold);
end

