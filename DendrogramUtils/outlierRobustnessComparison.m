function [misclassErr, ariScore, nmiScore, l1, l2] = outlierRobustnessComparison(X, G)

    misclassErr = zeros(0, 2);
    ariScore = zeros(0, 2);
    nmiScore = zeros(0, 2);
    l1 = [];
    l2 = [];
    
    k = 1;

    for outlier = 0:0.10:1
        tic
        
        K = 550; % num outliers
        m = outlier*K;
        Xnew = X(:, 1:550+m);
        
        N = size(Xnew, 2);
        [distFun, hpFun, ~, cardmss] = set_model('line');
        S = mssUniform(Xnew, 5*N, cardmss);
        H = hpFun(Xnew, S); 
        R = res(Xnew, H, distFun);
        P = prefMat(R, 0.75e-1, 1);
        
        [C, T] = tlnk(P);
        % C = outlier_rejection_card(C, cardmss);
        W = linkage_to_tree(T);
        root = W(end, 3);

        vals1 = 20:10:160;
        vals2 = 20:10:160;
        
        Gnew = G(1:550+m);

        [bestLambda1, bestLambda2] = computeBestParams(root, Xnew, W, ...
            Gnew, C, vals1, vals2);
        
        l1(end+1) = bestLambda1;
        l2(end+1) = bestLambda2;

        [~, ~, ~, ~, AltB] = exploreBFS(root, Xnew, W, bestLambda1, bestLambda2);
        lblsDynCut = labelsAfterDynCut(Xnew, W, AltB);
        [misclassErr(k, :), ariScore(k, :), nmiScore(k, :)] = compareClustering(Gnew, C, lblsDynCut);
        
        elapsed_time = toc;
        fprintf('Iteration %d took %f seconds\n', k, elapsed_time);
        
        k = k + 1;      
    end
end

