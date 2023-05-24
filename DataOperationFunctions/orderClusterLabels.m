function [Cnew] = orderClusterLabels(C, clusterSize)
% the most frequent label in x-th cluster is set as label x
% doesn't set label zero to the outliers in each cluster
% We trust that outlier rejection card di so

    if length(clusterSize) > 1
        beginningIdx = ones(length(clusterSize), 1);
        n = length(C);
        Cnew = C; % vector for new labels
        for i = 2:length(clusterSize)
            beginningIdx(i) = beginningIdx(i - 1) + clusterSize(i - 1);
        end
        for i = 1:length(clusterSize)
            indexes = beginningIdx(i):beginningIdx(i) + clusterSize(i) - 1;
            clusterLabels = C(indexes);
            [clusterMode, ~] = mode(clusterLabels);
            Cnew(C == clusterMode) = i;
        end
        Cnew = grp2idx(Cnew);
    else
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
end