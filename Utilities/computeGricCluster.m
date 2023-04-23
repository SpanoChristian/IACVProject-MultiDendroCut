function [clusterScore] = computeGricCluster(clusterIndex, X, tree)
%COMPUTEGRICCLUSTER Summary of this function goes here
%   Detailed explanation goes here

    clusterPoints = X(:, getLeavesFromNode(clusterIndex, tree));
    totalPoints = size(X,2);


    mi = fitline(clusterPoints);
    ri = res_line(clusterPoints, mi);

    rSqr = ri.^2;
    
    n = numel(rSqr)
    if n > 2
        [maxDistance, minDistance] = getMaxMinDistance(clusterPoints)
    else
        maxDistance = 0;
        minDistance = 1;
    end
    
    % Sum for number of rSqr element
    %dataFidelity = sum(min(rSqr./sigma^2, 2));
    
    dataError = min(mean(rSqr, 'omitnan'), 50) / n * 2 % include also total points (?)
    %modelComplexity = 1/(exp(-(((n-lambda1)/(lambda2)))^(2)));
    %modelComplexity = 10/(exp(-(((n-lambda1)/(lambda2)))^(2))+(1/10));
    notExplainedPercentage = (totalPoints - n)/totalPoints
    distanceRatio = maxDistance / minDistance
    gScore = dataError + notExplainedPercentage + distanceRatio


end

