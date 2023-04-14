function [misclassErr, ARI, NMI, ARINMI, lambda, thresholds] = ...
    inlierThresholdComparison(X, G, epsilonRange, model2fit)

    N = size(X, 2);
    
    [distFun, hpFun, ~, cardmss, isMergeableGricModel] = set_model(model2fit);
    
    nModelsToCheck = 3;
    misclassErr = zeros(0, nModelsToCheck); % rows correspond to different values of epsilon
    ARI = zeros(0, nModelsToCheck);
    NMI = zeros(0, nModelsToCheck);
    ARINMI = zeros(0, nModelsToCheck);
    lambda = [];
    thresholds = [];
    
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

        lambdaRange = 0:5:50;

        bestLambda = computeBestParams(root, X, W, ...
            G, C, lambdaRange, isMergeableGricModel, epsilon);
        
        lambda(end+1) = bestLambda;
        
        [~, meanN, stdN, confInt] = clusterNumPoints(C);

        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda, epsilon, ...
            isMergeableGricModel, false);
        
        
% I WAS EVALUATING WHAT IS THE BEST "CLUSTER THRESHOLD" (the one used in 
% 'labelsAfterDynCut'). Turns out that > 0 is the best -> some doubts about
% this result. I already obtained something like this and I am not sure it
% is correct... but we will see! ;)

%         best = 1;
%         bestThreshold = 20;
%         lblsDynCutBest = [];
%         for clusterThreshold = 0:2.5:40
%             lblsDynCut = labelsAfterDynCut(X, W, AltB, clusterThreshold);
%             [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
%             if best > ME(1, 2)
%                 best = ME(1, 2);
%                 bestThreshold = clusterThreshold;
%                 lblsDynCutBest = lblsDynCut;
%             end
%         end
%         
%         thresholds(end+1) = bestThreshold;
        
        %[ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
        
        %MEbefore = ME(1, 2);
        
        
        lblsDynCut = labelsAfterDynCut(X, W, AltB, 0);
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

