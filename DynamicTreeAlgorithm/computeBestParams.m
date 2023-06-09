function [bestLambda1, bestLambda2, minClusterThresholdLambda] = computeBestParams(root, X, W, G, C, range, ...
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
    bestClusterThresholdsLambda = zeros(0, 0);
    
    hw = waitbar(0, 'Computing best parameters...');
    
    k = 1;
    
    for lambda1 = range
        
        j = 1;
        for lambda2 = range
            [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, lambda1, lambda2, ...
                inlierThreshold, model2fit, false);

            best = 1;
            bestThreshold = 20;
            lblsDynCutBest = [];
            for clusterThreshold = 0:5:50
                
                lblsDynCut = labelsAfterDynCut(X, W, AltB, clusterThreshold, C);
                metricsDynTLinkage = compareClustering(G, lblsDynCut);

                if best > metricsDynTLinkage.misclassErr
                    best = metricsDynTLinkage.misclassErr;
                    bestThreshold = clusterThreshold;
                    lblsDynCutBest = lblsDynCut;
                end
            end
            
            lbls = labelsAfterDynCut(X, W, AltB, bestThreshold, C);
            
            %bestThresholdEst = -463.9973*inlierThreshold^2 + 239.1132*inlierThreshold + 7.6761;
            %lblsEst = labelsAfterDynCut(X, W, AltB, bestThreshold, C);

            metricsDynTLinkage = compareClustering(G, lbls);
            %metricsDynTLinkageEst = compareClustering(G, lblsEst);
            
            %bestClusterThresholdsEst(k, j) = bestThresholdEst;
            bestClusterThresholdsLambda(k, j) = bestThreshold;
            misclassErr(k, j) = metricsDynTLinkage.misclassErr;
            ARI(k, j) = metricsDynTLinkage.ariScore;
            NMI(k, j) = metricsDynTLinkage.nmiScore;
            
            %disp([["Best ME      : " misclassErr(k, j)];
            %      ["Estimated ME : " metricsDynTLinkageEst.misclassErr]])
            
            j = j + 1;
        
        end
        
        k = k + 1;
        
        waitbar(k/length(range), hw);
     
    end
    
    close(hw);
    
    minME = min(min(misclassErr));                                                                                                                                   
    [minRow, minCol] = find(misclassErr==minME);                                                                                                                     
    bestLambda1 = range(minRow(1));                                                                                                                                  
    bestLambda2 = range(minCol(1)); 
    
    % Threshold corresponding to the best lambda 1 and lambda 2
    % namely, lambda_1 and lambda_2 that minimize the ME
    minClusterThresholdLambda = bestClusterThresholdsLambda(minRow(1), minCol(1));
end
