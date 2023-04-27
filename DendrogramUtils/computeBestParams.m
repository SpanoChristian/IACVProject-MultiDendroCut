function [bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, C, range, ...
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

    ARI = zeros(0, 0);
    NMI = zeros(0, 0);
    misclassErr = zeros(0, 0);
    
    k = 1;
    
    for lambda1 = range
        
        j = 1;
        for lambda2 = range
            [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, lambda1, lambda2, ...
                inlierThreshold, model2fit, false);

            best = 1;
            bestThreshold = 20;
            lblsDynCutBest = [];
            for clusterThreshold = 0:5:35
                lblsDynCut = labelsAfterDynCut(X, W, AltB, clusterThreshold, C);
                [ME, ~, ~, ~] = compareClustering(G, C, lblsDynCut);
                if best > ME(1, 2)
                    best = ME(1, 2);
                    bestThreshold = clusterThreshold;
                    lblsDynCutBest = lblsDynCut;
                end
            end
            
            lbls = labelsAfterDynCut(X, W, AltB, bestThreshold, C);

            [ME, ari, nmi, ~] = compareClustering(G, C, lbls);

            misclassErr(k, j) = ME(2);
            ARI(k, j) = ari(2);
            NMI(k, j) = nmi(2);
            
            j = j + 1;
        
        end
        
        k = k + 1;  
     
    end
    
    minME = min(min(misclassErr));                                                                                                                                   
    [minRow, minCol] = find(misclassErr==minME);                                                                                                                     
    bestLambda1 = range(minRow(1));                                                                                                                                  
    bestLambda2 = range(minCol(1)); 
    
%     minME = min(misclassErr);
%     idxMinME = find(misclassErr==minME);
%     bestLambda = range(idxMinME(1));
    
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

