function [bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, C, vals1, vals2)
    misclassErr = zeros(length(vals1), length(vals2));
    
%     wait_step = 1; % Update waitbar every wait_step iterations
%     h = waitbar(0, 'Looking for the best params for the best cut...');
    
    k1 = 1;

    for lambda1 = vals1
        k2 = 1;
        for lambda2 = vals2
            [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, lambda1, lambda2);
            lbls = labelsAfterDynCut(X, W, AltB);
            [ME, ~, ~] = compareClustering(G, C, lbls);
            misclassErr(k1, k2) = ME(2);
            k2 = k2 + 1;
        end
%         perc = round(k1/length(vals1), 2);
%         if mod(k1, wait_step) == 0
%             waitbar(perc, h, sprintf('Looking for the best params for the best cut... %d%%', round(perc*100)));
%         end
        
        k1 = k1 + 1;
    end

    minME = min(min(misclassErr));
    [minRow, minCol] = find(misclassErr==minME);
    bestLambda1 = vals1(minRow(1));
    bestLambda2 = vals2(minCol(1));
end

