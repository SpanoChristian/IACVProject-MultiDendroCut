function bestLambda = computeBestParams(root, X, W, G, C, range, ...
    model2fit, inlierThreshold)
    
% ComputeBestParams: compute parameters that return the smallest clustering
% error
% INPUT
%   root: index of cluster that is root of tree
%   X: all points
%   W: matrix defining the tree (... x 3: (first to indexes are linked in
%   third)
%   G: ground truth for each point
%   C: assigned cluster by the algorithm
%   range: possible values of lambda
%   model2fit: %TODO
%   inlierThreshold: not used in called functions


    ARI = zeros(length(range), 0);
    NMI = zeros(length(range), 0);
    misclassErr = zeros(length(range), 0);
    
    for lambda = range
        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, lambda, ...
            inlierThreshold, model2fit, false);

        lbls = labelsAfterDynCut(X, W, AltB, 0);
        
        metrics = compareClustering(G, lbls);
        
        misclassErr(end+1) = metrics.misclassErr;
        ARI(end+1) = metrics.ariScore;
        NMI(end+1) = metrics.nmiScore;
    end
    
    minME = min(misclassErr);
    idxMinME = find(misclassErr==minME);
    bestLambda = range(idxMinME(1));
end