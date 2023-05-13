close all % close all figures
addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation

plotBoundaries = 1.1;
showGraphs = false;

graphsFolderImgsInlier = "Graphs/Images/InlierVariation/";
graphsFolderFigsInlier = "Graphs/Figures/InlierVariation/";
graphsFolderImgsOutlier = "Graphs/Images/OutlierVariation/";
graphsFolderFigsOutlier = "Graphs/Figures/OutlierVariation/";

clusterSize = 50;
clusterThreshold = 25;
labelled_data = false;
[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, datasetTitle] = getDatasetAndInfo(labelled_data, 2);
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = set_model('line');

gscatter(X(1, :), X(2, :), G)

epsilonRange = linspace(0.01, 0.25, 8);
outlierRange = linspace(nTotPoints-nRealPoints, nTotPoints, 8);
%epsilonRange = 0.12; % An inlier threshold value epsilon has to be specified.

bestThresholds = [];

idxOutlier = 1;

outlierLen = length(outlierRange);
epsilonLen = length(epsilonRange);

tLinkageME = zeros(outlierLen, epsilonLen);
dynTLinkageME = zeros(outlierLen, epsilonLen);
lofDynTLinkageME = zeros(outlierLen, epsilonLen);
bestThresholdsLambda = zeros(outlierLen, epsilonLen);
bestThresholdsInlier = zeros(outlierLen, epsilonLen);
lambda1 = zeros(outlierLen, epsilonLen);
lambda2 = zeros(outlierLen, epsilonLen);


for outlier = floor(outlierRange)
    
    disp("Outlier Iteration " + idxOutlier + " of " + outlierLen)
    
    [X, G, nTotPoints, nRealPoints, nOutliers, nClusters, datasetTitle] = getDatasetAndInfo(labelled_data, 2);
    X = X(:, 1:outlier);
    
    N = size(X, 2);
    
    if ~labelled_data
        G = generateGTLbls(nClusters, 50, outlier-250); %#ok<UNRCH>
    end
    
    S = mssUniform(X, 5*N, cardmss);
    H = hpFun(X, S); 
    R = res(X, H, distFun);
    
    for idxEps = 1:length(epsilonRange)

        if length(epsilonRange) > 1
            display("Inlier threshold variation " + idxEps + " out of " + length(epsilonRange))
        end

        epsilon = epsilonRange(idxEps);
        
        P = prefMat(R, epsilon, 1);

        %% Perform T-Linkage
        [lblsTLinkage, T] = tlnk(P);
        
        tree = linkage_to_tree(T); %just for debugging
        if length(epsilonRange) == -1
            printBranches(tree, X, 999);
        end

        %% Perform Dynamic T-Linkage
        [lblsDynTLinkage, bestLambda1, bestLambda2, bestThresholdLambda, toMergeClusters] = dynamicTLinkage(X, T, G, lblsTLinkage, epsilon, isMergeableGricModel, clusterThreshold);
        
        best = 1;
        bestThresholdInlier = 20;
        for clusterThreshold = 0:5:40

            lblsDynCut = labelsAfterDynCut(X, tree, toMergeClusters, clusterThreshold, lblsTLinkage);
            metricsDynTLinkage = compareClustering(G, lblsDynCut);
            
            disp([["ME Dyn : "  metricsDynTLinkage.misclassErr]; 
                  ["Best   : "  best]])

            if best > metricsDynTLinkage.misclassErr
                best = metricsDynTLinkage.misclassErr;
                bestThresholdInlier = clusterThreshold;
            end
            disp([["Threshold : " clusterThreshold];
                  ["Best      : " bestThresholdInlier]])
        end
        
        lambda1(idxOutlier, idxEps) = bestLambda1;
        lambda2(idxOutlier, idxEps) = bestLambda2;
        bestThresholdsLambda(idxOutlier, idxEps) = bestThresholdLambda;
        bestThresholdsInlier(idxOutlier, idxEps) = bestThresholdInlier;

        %% Outlier rejection step

        %T-Linkage fit a model to all the data points. Outlier can be found in
        %different ways (T-Linkage is agonostic about the outlier rejection strategy),
        %for example discarding too small cluster, or exploiting the randomness of
        %a model.

        lblsTLinkage = operateOnOutliers(lblsTLinkage, cardmss);
        %lblsDynTLinkage = operateOnOutliers(lblsDynTLinkage, cardmss);


        %% Order labels step
        lblsTLinkage = orderClusterLabels(lblsTLinkage, clusterSize, nTotPoints);
        lblsDynTLinkage = orderClusterLabels(lblsDynTLinkage, clusterSize, nTotPoints);

        candidateOutliers = LOF(X');
        lblsLOFDynCut = lblsDynTLinkage;
        lblsLOFDynCut(candidateOutliers) = 0;
        %% Showing results
        if length(epsilonRange) == 1
            figure('name','Assigned labels')
            s = subplot(1,3,1); gscatter(X(1,:),X(2,:), G); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('GroundTruth'); legend off
            s = subplot(1,3,2); gscatter(X(1,:),X(2,:), lblsTLinkage); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('T linkage'); legend off
            s = subplot(1,3,3); gscatter(X(1,:),X(2,:), lblsDynTLinkage); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('Dyn T linkage'); legend off
        end

        %% Compare clustering
        tLinkageMetrics = compareClustering(G, lblsTLinkage);
        dynTLinkageMetrics = compareClustering(G, lblsDynTLinkage);
        LOFdynTLinkageMetrics = compareClustering(G, lblsLOFDynCut);
        
        tLinkageME(idxOutlier, idxEps) = tLinkageMetrics.misclassErr;
        dynTLinkageME(idxOutlier, idxEps) = dynTLinkageMetrics.misclassErr;
        lofDynTLinkageME(idxOutlier, idxEps) = LOFdynTLinkageMetrics.misclassErr;
        
        %metrics(idxOutlier, eps).tLinkage = tLinkageMetrics;
        %metrics(idxOutlier, eps).dynTLinkage = dynTLinkageMetrics;
        %metrics(idxOutlier, eps).LOFdynTLinkage = LOFdynTLinkageMetrics;
    end
    
    idxOutlier = idxOutlier + 1;
    
end  % End-For outlier variation

% x = cols = epsilon
% y = rows = outliers
outlierRange = ((outlierRange-250)/250);
figure
surface(epsilonRange, outlierRange, tLinkageME, 'FaceColor', "#0072BD")
hold on
surface(epsilonRange, outlierRange, dynTLinkageME, 'FaceColor', "#D95319")
surface(epsilonRange, outlierRange, lofDynTLinkageME, 'FaceColor', "#EDB120")
ylabel("Outliers")
xlabel("\epsilon")
zlabel("ME(outlier, \epsilon)")
title("ME based on outlier and inlier threshold")
legend("T-Link", "Dyn T-Link", "LOF Dyn T-Link")

hold off

%% Different parameter comparisons
if length(epsilonRange) > 1
    finalTLinkageMetric = [metrics.tLinkage];
    finalDynTLinkageMetric = [metrics.dynTLinkage];
    finalLOFDynTLinkageMetric = [metrics.LOFdynTLinkage];
%% INLIER ARI COMPARISON
    figure('name','Ari')
    plot(epsilonRange, [finalTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "o")
    hold on
    plot(epsilonRange, [finalDynTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "+")
    plot(epsilonRange, [finalLOFDynTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "s")
    lgd = legend("T-Link ME", "Dyn T-Link ME", "LOF Dyn T-Link");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("ARI", "FontSize", 14)
    ylim([0 0.8])
    saveas(gcf, graphsFolderImgsInlier + datasetTitle + "_ARI", 'png');
    saveas(gcf, graphsFolderFigsInlier + datasetTitle + "_ARI");


    %% MISCLASS ERROR
    figure('name','Misclassification Error')
    plot(epsilonRange, [finalTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "o")
    hold on
    plot(epsilonRange, [finalDynTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "+")
    plot(epsilonRange, [finalLOFDynTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "s")
    lgd = legend("T-Link ME", "Dyn T-Link ME", "LOF Dyn T-Link");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("Misclassification Error %", "FontSize", 14)
    ylim([0 0.8])
    %%%%%%%%%%%%%%%%%%%%%%% HERE
    saveas(gcf, graphsFolderImgsInlier + datasetTitle + "_ME", 'png');
    saveas(gcf, graphsFolderFigsInlier + datasetTitle + "_ME");

    %% INLIER THRESHOLD - PARAMETER LAMBDA 1
    figure
    plot(epsilonRange, lambda1, "s-", "LineWidth", 2, "Color", "#0072BD")
    yline(mean(lambda1), "--", mean(lambda1), "LineWidth", 2.3, "Color", "#D95319", ...
        "LabelVerticalAlignment", "Bottom", ...
        "FontSize", 15)
    title("Variation of lambda parameter based on \epsilon")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("\lambda_{1}(\epsilon)", "FontSize", 16)
    legend("\lambda_{1}(\epsilon)", "FontSize", 16)
    xlim([min(epsilonRange)-0.005, max(epsilonRange)+0.005])
    ylim([0, max(lambda1)+15])
    saveas(gcf, graphsFolderImgsInlier + datasetTitle + "_Lambda1Variation", 'png');
    saveas(gcf, graphsFolderFigsInlier + datasetTitle + "_Lambda1Variation");


    %% INLIER THRESHOLD - PARAMETER LAMBDA 2
    figure
    plot(epsilonRange, lambda2, "s-", "LineWidth", 2, "Color", "#0072BD")
    yline(mean(lambda2), "--", mean(lambda2), "LineWidth", 2.3, "Color", "#D95319", ...
        "LabelVerticalAlignment", "Bottom", ...
        "FontSize", 15)
    title("Variation of lambda parameter based on \epsilon")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("\lambda_{2}(\epsilon)", "FontSize", 16)
    legend("\lambda_{2}(\epsilon)", "FontSize", 16)
    xlim([min(epsilonRange)-0.005, max(epsilonRange)+0.005])
    ylim([0, max(lambda2)+15])
   
    saveas(gcf, graphsFolderImgsInlier + datasetTitle + "_Lambda2Variation", 'png');
    saveas(gcf, graphsFolderFigsInlier + datasetTitle + "_Lambda2Variation");
    
    %% Improvement Comparison - How much our algorithm impact on ME?
    
    % LOF Dynamic T-Linkage vs T-Linkage
    LOFDynVsTlnk = [finalLOFDynTLinkageMetric.misclassErr] - [finalTLinkageMetric.misclassErr];
    
    % Dynamic T-Linkage vs T-Linkage
    DynVsTlnk = [finalDynTLinkageMetric.misclassErr] - [finalTLinkageMetric.misclassErr];
    
    figure
    bar(epsilonRange, [LOFDynVsTlnk; DynVsTlnk])
    legend("LOF", "DYN", "Location", "Best", "FontSize", 14)
    title("Delta ME [LOF] Dyn T-Link vs T-Link", "FontSize", 15)
    xlabel("\epsilon", "FontSize", 16)
    ylabel("Delta % ME", "FontSize", 15)
    %xlim([min(epsilonRange)-0.05, max(epsilonRange)+0.005])
    ylim( [ ...
        min( ...
            [LOFDynVsTlnk'; DynVsTlnk'] ...
        )-0.05, ...
        max( ...
            [LOFDynVsTlnk'; DynVsTlnk'] ...
        )+0.05 ])
    
    saveas(gcf, graphsFolderImgsInlier + datasetTitle + "_ImprovementPerc", 'png');
    saveas(gcf, graphsFolderFigsInlier + datasetTitle + "_ImprovementPerc");
    
end



%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it