close all % close all figures
addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation

plotBoundaries = 1.1;
showGraphs = false;

clusterSize = 50;
clusterThreshold = 25;
labelled_data = false;
[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = set_model('line');

% move generateGTLbls into getDatasetAndInfo
 if ~labelled_data
        G = generateGTLbls(nClusters, clusterSize, nOutliers); %#ok<UNRCH>
end

epsilonRange = linspace(0.02, 0.25, 2);
epsilonRange = 0.085; % An inlier threshold value  epsilon has to be specified.

outlierRange = 0:0.05:1; % TODO to use

lambda1 = [];
lambda2 = [];

for i=1:length(epsilonRange)
    
    if length(epsilonRange) > 1
        display("Inlier threshold variation " + i + " out of " + length(epsilonRange))
    end
    
    epsilon = epsilonRange(i);
    
    %% Perform T-Linkage
    [lblsTLinkage, T] = t_linkage(X, distFun, epsilon, cardmss, hpFun);
    tree = linkage_to_tree(T); %just for debugging
    if length(epsilonRange) == -1
        printBranches(tree, X, 999);
    end

    %% Perform Dynamic T-Linkage
    [lblsDynTLinkage, bestLambda1, bestLambda2]  = dynamicTLinkage(X, T, G, lblsTLinkage, epsilon, isMergeableGricModel, clusterThreshold);


   
    lambda1(end + 1) = bestLambda1;
    lambda2(end + 1) = bestLambda2;

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


    metrics(i).tLinkage = tLinkageMetrics;
    metrics(i).dynTLinkage = dynTLinkageMetrics;
    

end


%% Different parameter comparisons
if length(epsilonRange) > 1
%% INLIER ARI COMPARISON
    finalTLinkageMetric = [metrics.tLinkage];
    finalDynTLinkageMetric = [metrics.dynTLinkage];
    figure('name','Ari')
    plot(epsilonRange, [finalTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "o")
    hold on
    plot(epsilonRange, [finalDynTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "+")
    lgd = legend("T-Linkage ARI", "Dynamic T-Linkage ARI");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. LOF Dynamic T-Linkage")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("ARI", "FontSize", 14)
    ylim([0 0.8])


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
end



%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it