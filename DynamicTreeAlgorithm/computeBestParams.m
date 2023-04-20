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
%   vals1: possible values of param 
%   inlierThreshold: not used in called functions

    ARI = zeros(length(range), 0);
    NMI = zeros(length(range), 0);
    misclassErr = zeros(length(range), 0);
    
    for lambda = range
        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, lambda, ...
            inlierThreshold, model2fit, false);

        lbls = labelsAfterDynCut(X, W, AltB, 0);
        
        [ME, ari, nmi, ~] = compareClustering(G, C, lbls);
        
        misclassErr(end+1) = ME(2);
        ARI(end+1) = ari(2);
        NMI(end+1) = nmi(2);
    end
    
    minME = min(misclassErr);
    idxMinME = find(misclassErr==minME);
    bestLambda = range(idxMinME(1));
    
%     maxNMI = max(max(NMI));
%     [maxRow, maxCol] = find(NMI==maxNMI);
%     bestLambda1 = vals1(maxRow(1));
%     bestLambda2 = vals2(maxCol(1));
%     
%     maxARI = max(max(ARI));
%     [maxRow, maxCol] = find(ARI==maxARI);
%     bestLambda1 = vals1(maxRow(1));
%     bestLambda2 = vals2(maxCol(1));
% 
%     ARINMI = ARI.*NMI;
%     maxARINMI = max(max(ARINMI));
%     [maxRow, maxCol] = find(ARINMI==maxARINMI);
%     bestLambda1 = vals1(maxRow(1));
%     bestLambda2 = vals2(maxCol(1));
end

