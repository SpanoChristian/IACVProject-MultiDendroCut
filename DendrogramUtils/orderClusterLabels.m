function [Cnew] = orderClusterLabels(C, clusterSize)
% the most frequent label in x-th cluster is set as label x
% doesn't set label zero to the outliers in each cluster
% We trust that outlier rejection card di so

    n = length(C);
    i = 1;
    Cnew = C; % vector for new labels
    for beginningClusterIdx = 1:clusterSize:n
        indexes = beginningClusterIdx:beginningClusterIdx + clusterSize - 1;
        clusterLabels = C(indexes);
        [clusterMode, ~] = mode(clusterLabels);
        Cnew(C == clusterMode) = i;
    
        i=i+1;
    end
    Cnew = grp2idx(Cnew);
end