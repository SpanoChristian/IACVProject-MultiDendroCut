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
%   range: possible values of lambda
%   model2fit: %TODO
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
                metricsDynTLinkage = compareClustering(G, lblsDynCut);

                if best > metricsDynTLinkage.misclassErr
                    best = metricsDynTLinkage.misclassErr;
                    bestThreshold = clusterThreshold;
                    lblsDynCutBest = lblsDynCut;
                end
            end
            
            lbls = labelsAfterDynCut(X, W, AltB, bestThreshold, C);

            metricsDynTLinkage = compareClustering(G, lblsDynCut);

            misclassErr(k, j) = metricsDynTLinkage.misclassErr;
            ARI(k, j) = metricsDynTLinkage.ariScore;
            NMI(k, j) = metricsDynTLinkage.nmiScore;
            
            j = j + 1;
        
        end
        
        k = k + 1;  
     
    end
    
    minME = min(min(misclassErr));                                                                                                                                   
    [minRow, minCol] = find(misclassErr==minME);                                                                                                                     
    bestLambda1 = range(minRow(1));                                                                                                                                  
    bestLambda2 = range(minCol(1)); 
end
