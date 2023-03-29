function [misclassErr, ariScore, nmiScore, l1, l2] = outliersRobustnessComparison(X, G)

    N = size(X, 2);
    [distFun, hpFun, ~, cardmss] = set_model('line');
    S = mssUniform(X, 5*N, cardmss);
    H = hpFun(X, S); 
    R = res(X, H, distFun);
    misclassErr = zeros(0, 2);
    ariScore = zeros(0, 2);
    nmiScore = zeros(0, 2);
    l1 = [];
    l2 = [];
    
    k = 1;

    for epsilon = 0.01:0.015:0.2
        tic
        P = prefMat(R, epsilon, 1);
        [C, T] = tlnk(P);
        C = outlier_rejection_card(C, cardmss);
        W = linkage_to_tree(T);
        root = W(end, 3);

        vals1 = 20:10:160;
        vals2 = 20:10:160;

        [bestLambda1, bestLambda2] = computeBestParams(root, X, W, ...
            G, C, vals1, vals2);
        
        l1(end+1) = bestLambda1;
        l2(end+1) = bestLambda2;

        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda1, bestLambda2);
        lblsDynCut = labelsAfterDynCut(X, W, AltB);
        [misclassErr(k, :), ariScore(k, :), nmiScore(k, :)] = compareClustering(G, C, lblsDynCut);
        
        elapsed_time = toc;
        fprintf('Iteration %d took %f seconds\n', k, elapsed_time);
        
        k = k + 1;      
    end
end

