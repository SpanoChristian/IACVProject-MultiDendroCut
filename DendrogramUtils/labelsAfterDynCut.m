function lbls = labelsAfterDynCut(X, tree, AltB)
    sizeAltB = length(AltB);
    lbls = zeros(length(X), 1);
    l = 0;
    
    for i = 1:sizeAltB
        idxAB = get_cluster_idxPoints(AltB(i), X, tree);
        P = get_cluster_points(X, idxAB);
        if length(P) > 30
            l = l + 1;
            lbls(idxAB) = l;
        end
    end
end

