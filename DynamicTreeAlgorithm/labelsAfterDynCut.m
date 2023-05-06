function lbls = labelsAfterDynCut(X, tree, AltB, clusterThreshold, C)
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
        [idxAB, P] = getClusterPoints(AltB(i), X, tree);
        if length(P) > clusterThreshold
            l = l + 1;
            lbls(idxAB) = l;
        end
    end
    
	lbls = orderClusterLabels(lbls, 50, length(lbls));
	
end

