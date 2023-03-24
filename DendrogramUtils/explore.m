function [C, T] = explore(C, X, tree)
    [childL, childR] = get_children(C, tree);
   
    XL = X(:, get_cluster_idxPoints(childL, X, tree));
    XR = X(:, get_cluster_idxPoints(childR, X, tree));
    X = X(:, get_cluster_idxPoints(C, X, tree));
    
    [C, T] = tlinkage(XR);
end

