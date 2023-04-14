function [bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, C, vals1, vals2, inlierThreshold)
    
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

    ARI = zeros(length(vals1), length(vals2));
    NMI = zeros(length(vals1), length(vals2));
    misclassErr = zeros(length(vals1), length(vals2));
    
%     wait_step = 1; % Update waitbar every wait_step iterations
%     h = waitbar(0, 'Looking for the best params for the best cut...');
    
    k1 = 1;

    for lambda1 = vals1
        k2 = 1;
        for lambda2 = vals2
            [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, lambda1, lambda2, inlierThreshold);
            lbls = labelsAfterDynCut(X, W, AltB);
            [ME, ari, nmi, ~] = compareClustering(G, C, lbls);
            misclassErr(k1, k2) = ME(2);
            ARI(k1, k2) = ari(2);
            NMI(k1, k2) = nmi(2);
            k2 = k2 + 1;
        end
%         perc = round(k1/length(vals1), 2);
%         if mod(k1, wait_step) == 0
%             waitbar(perc, h, sprintf('Looking for the best params for the best cut... %d%%', round(perc*100)));
%         end
        
        k1 = k1 + 1;
    end
%   
    minME = min(min(misclassErr));
    [minRow, minCol] = find(misclassErr==minME);
    bestLambda1 = vals1(minRow(1));
    bestLambda2 = vals2(minCol(1));
    
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

