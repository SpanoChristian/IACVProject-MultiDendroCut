function lbls = labelsAfterDynCut(X, tree, AltB, clusterThreshold)
%LABELSAFTERDYNCUT assign cluster to points
% Inputs
%   X: list of points
%   tree: tree obtained from the dendrogram
%   AltB: name of clusters that are better merged than splitted
% Outputs
%   lbls: for each point, it says the label it has been assigned to

    sizeAltB = length(AltB);
    lbls = zeros(length(X), 1);
    l = 0;
    
    for i = 1:sizeAltB
        idxAB = get_cluster_idxPoints(AltB(i), X, tree);
        P = get_cluster_points(X, idxAB);
        % With circles I used: 18
        if length(P) > clusterThreshold
            l = l + 1;
            lbls(idxAB) = l;
        end
    end
    
    %lbls = orderClusterLabels(lbls, 50);

    for i = 1: length(lbls)
        if lbls(i) == 0
            lbls(i) = i + max(lbls);
            i=i+1;
        end
    end
end

