function [misclassErr, ARI, NMI, ARINMI, l1, l2] = inlierThresholdComparison(X, G, epsilonRange)

    N = size(X, 2);
    [distFun, hpFun, ~, cardmss] = set_model('line');
    nModelsToCheck = 3;
    misclassErr = zeros(0, nModelsToCheck); % rows correspond to different values of epsilon
    ARI = zeros(0, nModelsToCheck);
    NMI = zeros(0, nModelsToCheck);
    ARINMI = zeros(0, nModelsToCheck);
    l1 = [];
    l2 = [];
    
    k = 1;

    for epsilon = epsilonRange
        tic
        S = mssUniform(X, 5*N, cardmss);
        H = hpFun(X, S); 
        R = res(X, H, distFun);
        P = prefMat(R, epsilon, 1);
        [C, T] = tlnk(P);
        % C = outlier_rejection_card(C, cardmss);
        W = linkage_to_tree(T);
        root = W(end, 3);

        vals1 = 1:1:1;
        vals2 = 0:5:50;

        [bestLambda1, bestLambda2] = computeBestParams(root, X, W, ...
            G, C, vals1, vals2, epsilon);
        
        l1(end+1) = bestLambda1;
        l2(end+1) = bestLambda2;
        
        [~, meanN, stdN, confInt] = clusterNumPoints(C);

        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda1, bestLambda2, epsilon);
        lblsDynCut = labelsAfterDynCut(X, W, AltB);
        
        %[ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
        
        %MEbefore = ME(1, 2);
        
        
        
         % compare TLinkage and DynTLinkage
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
        %ME(:,1) ME T-Link
        %ME(:,2) ME Dyn T-Link


        misclassErr(k, 1:2) = ME;
        ARI(k, 1:2) = ariScore;
        NMI(k, 1:2) = nmiScore;
        ARINMI(k, 1:2) = arinmiScore;

        % Apply LOF
        % --- We trust T-Linkage --- (we trust its detected outliers are real outliers)
        % If I have very few outliers using LOF makes the clustering worse
        % Apply LOF only if >=30% of points are outliers
        % disp("Outlier % : " + sum(C == 0)/length(C))
        %if sum(C == 0)/length(C) >= 0.3
            candidateOutliers = outliersNeighbour(X');
            lblsDynCut(candidateOutliers) = 0;
        %end

         % compare TLinkage and DynTLinkage
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
        %ME(:,1) ME T-Link
        %ME(:,2) ME Dyn T-Link with LOF

        misclassErr(k, 3) = ME(1,2);
        ARI(k, 3) = ariScore(1,2);
        NMI(k, 3) = nmiScore(1,2);
        ARINMI(k, 3) = arinmiScore(1,2);
        
        %MEafter = ME(1, 2);
  %         
%         if ME(1, 1) < ME(1, 2)
%             flagME = true;
%         else
%             flagME = false;
%         end
%         
%         if MEbefore < MEafter
%             dispME = "NO lof";
%         else
%             dispME = "APPLY lof";
%         end
        
        
        
        elapsed_time = toc;
        fprintf('Iteration %d took %f seconds\n', k, elapsed_time);
%         disp([["lambda1   : " l1(end)]; ["lambda2   : " l2(end)];
%               ["Outlier % : " sum(C == 0)/length(C)];
%               ["CI Low    : " confInt(1, 1)];
%               ["CI High   : " confInt(1, 2)];
%               ["ME T-link : " ME(1, 1)];
%               ["ME Dyn T  : " ME(1, 2)];
%               ["ME Top    : " flagME];
%               ["LOF?      : " dispME]])
        
        k = k + 1;      
    end
end

