function [misclassErr, ARI, NMI, ARINMI, lambda, thresholds] = ...
    outlierRobustnessComparison(X, G, numOutliers, model2fit, ...
        inlierThreshold)

    nModelsToCheck = 3;
    misclassErr = zeros(0, nModelsToCheck); % rows correspond to different values of epsilon
    ARI = zeros(0, nModelsToCheck);
    NMI = zeros(0, nModelsToCheck);
    ARINMI = zeros(0, nModelsToCheck);
    lambda = [];
    thresholds = [];
    
    [distFun, hpFun, ~, cardmss, isMergeableGricModel] = set_model(model2fit);
    
    k = 1;

    for outlier = 0:0.2:1
        tic
        
        m = outlier*numOutliers;
        Xnew = X(:, 1:numOutliers+m);
        
        N = size(Xnew, 2);
        S = mssUniform(Xnew, 5*N, cardmss);
        H = hpFun(Xnew, S); 
        R = res(Xnew, H, distFun);
        P = prefMat(R, inlierThreshold, 1);
        
        [C, T] = tlnk(P);
        C = outlier_rejection_card(C, cardmss);
        
        Cnew = orderClusterLabels(C, 50);
        %Cnew(Cnew == max(Cnew)) = 0;  
        C = Cnew;
        
        numOutliersFromTlnk = sum(C == 0)/length(C);
        
        h = 16*numOutliersFromTlnk;
        f = 0.8 + 4.5*numOutliersFromTlnk;
        g = (1 - 2.17)*numOutliersFromTlnk + 2.17;
        %g = 0.985*(numOutliersFromTlnk - 1.2)^2 + 0.955;
        
        if numOutliersFromTlnk <= 0.15
            adjNumOutliersFromTlnk = h * numOutliersFromTlnk;
        elseif numOutliersFromTlnk > 0.15 && numOutliersFromTlnk <= 0.35
            adjNumOutliersFromTlnk = f * numOutliersFromTlnk;
        else
            adjNumOutliersFromTlnk = g * numOutliersFromTlnk;
        end
        
        fittedModel = -14.27*outlier.^2 + ...
            34.05*outlier + 0.926;
        
        disp(["TLnk Outliers Est : " adjNumOutliersFromTlnk " vs. " outlier])
        
        W = linkage_to_tree(T);
        root = W(end, 3);

        lambdaRange = 0:5:50;
        
        Gnew = G(1:numOutliers+m);

        bestLambda = computeBestParams(root, Xnew, W, ...
            Gnew, C, lambdaRange, isMergeableGricModel, inlierThreshold, ...
            fittedModel);
        
        lambda(end+1) = bestLambda;
        
        [~, ~, ~, ~, AltB] = exploreDFS(root, Xnew, W, bestLambda, ...
                 inlierThreshold, isMergeableGricModel, false);
        
        %[~, meanN, stdN, confInt] = clusterNumPoints(C);
        
%         best = 1;
%         bestThreshold = 0.085;
%         for inlier = linspace(0.05, 0.2, 10)
%             [~, ~, ~, ~, AltB] = exploreDFS(root, Xnew, W, bestLambda, ...
%                 inlier, isMergeableGricModel, false);
%             lblsDynCut = labelsAfterDynCut(Xnew, W, AltB, fittedModel);
%             [ME, ~, ~, ~] = compareClustering(Gnew, C, lblsDynCut);
%             if best > ME(1, 2)
%                 best = ME(1, 2);
%                 bestThreshold = inlier;
%                 lblsDynCutBest = lblsDynCut;
%             end
%         end
%         
%         thresholds(end+1) = bestThreshold;
%         
%         best = 1;
%         bestThreshold = 20;
%         lblsDynCutBest = [];
%         for clusterThreshold = 0:2.5:40
%             lblsDynCut = labelsAfterDynCut(Xnew, W, AltB, clusterThreshold);
%             [ME, ~, ~, ~] = compareClustering(Gnew, C, lblsDynCut);
%             if best > ME(1, 2)
%                 best = ME(1, 2);
%                 bestThreshold = clusterThreshold;
%                 lblsDynCutBest = lblsDynCut;
%             end
%         end
%         
%         thresholds(end+1) = bestThreshold;
        
%        disp(["Estimated Threshold : " fittedModel " vs. " bestThreshold])
        
        lblsDynCut = labelsAfterDynCut(Xnew, W, AltB, fittedModel);
        
        disp([["G length   : " length(Gnew)];
              ["C length   : " length(C)];
              ["Dyn length : " length(lblsDynCut)];])
        
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(Gnew, C, lblsDynCut);
        
        misclassErr(k, 1:2) = ME;
        ARI(k, 1:2) = ariScore;
        NMI(k, 1:2) = nmiScore;
        ARINMI(k, 1:2) = arinmiScore;
        
        %MEbefore = ME(1, 2);
        
        % --- We trust T-Linkage ---
        % If I have very few outliers using LOF makes the clustering worse
        % Apply LOF only if >=30% of points are outliers
        disp("Outlier % : " + sum(C == 0)/length(C))
        disp("Performance : " + sum(C == 0)/length(C))
        % if sum(C == 0)/length(C) > 0.2
        candidateOutliers = outliersNeighbour(Xnew');
        lblsDynCut(candidateOutliers) = 0;
        % end
        
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(Gnew, C, lblsDynCut);
        
%         MEafter = ME(1, 2);
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
        
        misclassErr(k, 3) = ME(1,2);
        ARI(k, 3) = ariScore(1,2);
        NMI(k, 3) = nmiScore(1,2);
        ARINMI(k, 3) = arinmiScore(1,2);
        
        elapsed_time = toc;
        fprintf('Iteration %d took %f seconds\n', k, elapsed_time);
%         disp([["lambda1   : " lambda(end)]; ["lambda2   : " l2(end)];
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

