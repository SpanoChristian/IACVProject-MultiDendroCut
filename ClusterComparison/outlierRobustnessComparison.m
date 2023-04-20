function [misclassErr, ARIscore, NMIscore, ARINMIscore, l1, l2] = outlierRobustnessComparison(X, G, numOutliers)

    misclassErr = zeros(0, 2);
    ARIscore = zeros(0, 2);
    NMIscore = zeros(0, 2);
    ARINMIscore = zeros(0, 2);
    l1 = [];
    l2 = [];
    
    k = 1;

    for outlier = 0:0.05:1
        tic
        
        m = outlier*numOutliers;
        Xnew = X(:, 1:numOutliers+m);
        
        N = size(Xnew, 2);
        [distFun, hpFun, ~, cardmss] = set_model('line');
        S = mssUniform(Xnew, 5*N, cardmss);
        H = hpFun(Xnew, S); 
        R = res(Xnew, H, distFun);
        epsilon = 0.05;
        P = prefMat(R, epsilon, 1);
        
        [C, T] = tlnk(P);
        % C = outlier_rejection_card(C, cardmss);
        W = linkage_to_tree(T);
        root = W(end, 3);

        vals1 = 10:10:10;
        vals2 = 0:5:50;
        
        Gnew = G(1:numOutliers+m);

        [bestLambda1, bestLambda2] = computeBestParams(root, Xnew, W, ...
            Gnew, C, vals1, vals2, epsilon);
        
        l1(end+1) = bestLambda1;
        l2(end+1) = bestLambda2;
        
        [~, meanN, stdN, confInt] = clusterNumPoints(C);

        [~, ~, ~, ~, AltB] = exploreDFS(root, Xnew, W, bestLambda1, bestLambda2, epsilon);
        lblsDynCut = labelsAfterDynCut(Xnew, W, AltB);
        
        disp([["G length   : " length(Gnew)];
              ["C length   : " length(C)];
              ["Dyn length : " length(lblsDynCut)];])
        
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(Gnew, C, lblsDynCut);
        
        MEbefore = ME(1, 2);
        
        % --- We trust T-Linkage ---
        % If I have very few outliers using LOF makes the clustering worse
        % Apply LOF only if >=30% of points are outliers
        disp("Outlier % : " + sum(C == 0)/length(C))
        if sum(C == 0)/length(C) > 0.2
            candidateOutliers = outliersNeighbour(Xnew');
            lblsDynCut(candidateOutliers) = 0;
        end
        
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(Gnew, C, lblsDynCut);
        
        MEafter = ME(1, 2);
        
        if ME(1, 1) < ME(1, 2)
            flagME = true;
        else
            flagME = false;
        end
        
        if MEbefore < MEafter
            dispME = "NO lof";
        else
            dispME = "APPLY lof";
        end
        
        misclassErr(k, :) = ME;
        ARIscore(k, :) = ariScore;
        NMIscore(k, :) = nmiScore;
        ARINMIscore(k, :) = arinmiScore;
        
        elapsed_time = toc;
        fprintf('Iteration %d took %f seconds\n', k, elapsed_time);
        disp([["lambda1   : " l1(end)]; ["lambda2   : " l2(end)];
              ["Outlier % : " sum(C == 0)/length(C)];
              ["CI Low    : " confInt(1, 1)];
              ["CI High   : " confInt(1, 2)];
              ["ME T-link : " ME(1, 1)];
              ["ME Dyn T  : " ME(1, 2)];
              ["ME Top    : " flagME];
              ["LOF?      : " dispME]])
        
        k = k + 1;      
    end
end

