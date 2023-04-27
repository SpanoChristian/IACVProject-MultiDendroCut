function [misclassErr, ARI, NMI, ARINMI, lambda1, lambda2, thresholds] = ...
        outlierVariationNew(model2fit, epsilon, outlierRange)

    addpath(genpath("."))

    k = 1;

    nModelsToCheck = 3;
    misclassErr = zeros(0, nModelsToCheck);
    ARI = zeros(0, nModelsToCheck);
    NMI = zeros(0, nModelsToCheck);
    ARINMI = zeros(0, nModelsToCheck);
    lambda1 = [];
    lambda2 = [];
    thresholds = [];

    labelled_data = false; 
    inliers = [];

    [distFun, hpFun, ~, cardmss, isMergeableGricModel] = set_model(model2fit);

    for i = floor(outlierRange)

        [X, G, ~, ~, ~, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);
        X = X(:, 1:i);

        N = size(X, 2);

        if ~labelled_data
            G = generateGTLbls(nClusters, 50, i-250); %#ok<UNRCH>
        end

        S = mssUniform(X, 5*N, cardmss);
        H = hpFun(X, S); 
        R = res(X, H, distFun);
        P = prefMat(R, epsilon, 1);

        [C, T] = tlnk(P);
        C = outlier_rejection_card( C, cardmss );
        C = orderLbls(C, 50, 500);

        W = linkage_to_tree(T);
        root = W(end, 3);

        lambdaRange = 0:5:80;

        [bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, C, lambdaRange, ...
           isMergeableGricModel, epsilon);

        lambda1(end+1) = bestLambda1;
        lambda2(end+1) = bestLambda2;

        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda1, bestLambda2, epsilon, ...
            isMergeableGricModel, false);

        best = 1;
        bestThreshold = 20;
        for clusterThreshold = 0:2.5:40
            lblsDynCut = labelsAfterDynCut(X, W, AltB, clusterThreshold, C);
            [ME, ~, ~, ~] = compareClustering(G, C, lblsDynCut);
            if best > ME(1, 2)
                best = ME(1, 2);
                bestThreshold = clusterThreshold;
            end
        end

        thresholds(end+1) = bestThreshold;

        lblsDynCut = labelsAfterDynCut(X, W, AltB, bestThreshold, C);
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);  

        misclassErr(k, 1:2) = ME;
        ARI(k, 1:2) = ariScore;
        NMI(k, 1:2) = nmiScore;
        ARINMI(k, 1:2) = arinmiScore;

        candidateOutliers = outliersNeighbour(X');
        lblsDynCut(candidateOutliers) = 0;
        [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);

        misclassErr(k, 3) = ME(1, 2);
        ARI(k, 3) = ariScore(1,2);
        NMI(k, 3) = nmiScore(1,2);
        ARINMI(k, 3) = arinmiScore(1,2);

        disp([["Outlier % : " ((i-250)/250)*100 + "%"]; 
             ["T-Linkage  : " misclassErr(end, 1)];
             ["DYN T-link : " misclassErr(end, 2)];
             ["LOFDYN T   : " misclassErr(end, 3)]])

        k = k + 1;

        disp(k)
    end

%     %% OUTLIER THRESHOLD ME COMPARISON
%     figure
%     plot(outlierRange, misclassErr(:, 1), "-", "LineWidth", 2, ...
%         "Marker", "o", "Color", "#0072BD")
%     hold on
%     plot(outlierRange, misclassErr(:, 2), "-", "LineWidth", 2, ...
%         "Marker", "+", "Color", "#D95319")
%     hold on
%     plot(outlierRange, misclassErr(:, 3), "-", "LineWidth", 2, ...
%         "Marker", "*", "Color", "#EDB120")
%     lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME", "LOF Dynamic T-Linkage ME");
%     lgd.FontSize = 15; % Change the font size to 14 points
%     title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage (" + datasetTitle + ")")
%     xlabel("Outlier %", "FontSize", 16)
%     ylabel("Misclassification Error", "FontSize", 14)
%     roof = max([misclassErr(:, 1); misclassErr(:, 2); misclassErr(:, 3)]);
%     xlim([min(outlierRange)-0.005, max(outlierRange)+0.005])
%     ylim([0, roof+0.15])
% 
%     saveas(gcf, graphsFolderImgsOutlier + datasetTitle + "_MEComparison", 'png');
%     saveas(gcf, graphsFolderFigsOutlier + datasetTitle + "_MEComparison");
% 
%     %%
%     % LOF Dynamic T-Linkage vs T-Linkage
%     LOFDynVsTlnk = misclassErr(:, 1) - misclassErr(:, 3);
% 
%     % Dynamic T-Linkage vs T-Linkage
%     DynVsTlnk = misclassErr(:, 1) - misclassErr(:, 2);
% 
%     figure
%     bar(outlierRange, [LOFDynVsTlnk'; DynVsTlnk'])
%     legend("LOF", "DYN", "Location", "Best", "FontSize", 14)
%     title("Improvement of [LOF] Dynamic T-Linkage", "FontSize", 15)
%     xlabel("Outlier %", "FontSize", 16)
%     ylabel("% ME Improved", "FontSize", 15)
% 
%     saveas(gcf, graphsFolderImgsOutlier + datasetTitle + "_ImprovementPerc", 'png');
%     saveas(gcf, graphsFolderFigsOutlier + datasetTitle + "_ImprovementPerc");

end