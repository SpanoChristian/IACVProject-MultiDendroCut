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

%gscatter(X(1, :), X(2, :), G)

% move generateGTLbls into getDatasetAndInfo
if ~labelled_data
    G = generateGTLbls(nClusters, clusterSize, nOutliers); %#ok<UNRCH>
end

epsilonRange = linspace(0.02, 0.25, 10);
epsilonRange = 0.12; % An inlier threshold value epsilon has to be specified.

outlierRange = linspace(250, 500, 10); % TODO to use

lambda1 = [];
lambda2 = [];
bestThresholds = [];
outlierIdx = 1;

for outlier = floor(outlierRange)
    display(outlierIdx + ": " + outlier + " points")
    [X, G, ~, ~, ~, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);
    X = X(:, 1:outlier);
    G = G(1:outlier);
    
    S = mssUniform(X, 5*nRealPoints, cardmss);
    H = hpFun(X, S); 
    R = res(X, H, distFun);
    
    for eps=1:length(epsilonRange)
        
        epsilon = epsilonRange(eps);
        
        P = prefMat(R, epsilon, 1);

        if length(epsilonRange) > 1
            display("Inlier threshold variation " + eps + " out of " + length(epsilonRange))
        end


        %% Perform T-Linkage
        [lblsTLinkage, T] = t_linkage(X, distFun, epsilon, cardmss, hpFun);
        tree = linkage_to_tree(T); %just for debugging
        if length(epsilonRange) == -1
            printBranches(tree, X, 999);
        end

        %% Perform Dynamic T-Linkage
        [lblsDynTLinkage, bestLambda1, bestLambda2, bestThreshold] = dynamicTLinkage(X, T, G, lblsTLinkage, epsilon, isMergeableGricModel, clusterThreshold);

        lambda1(end + 1) = bestLambda1;
        lambda2(end + 1) = bestLambda2;
        bestThresholds(end + 1) = bestThreshold;

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
        if length(epsilonRange) == 1 && length(outlierRange) == 1
            figure('name','Assigned labels')
            s = subplot(1,3,1); gscatter(X(1,:),X(2,:), G); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('GroundTruth'); legend off
            s = subplot(1,3,2); gscatter(X(1,:),X(2,:), lblsTLinkage); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('T linkage'); legend off
            s = subplot(1,3,3); gscatter(X(1,:),X(2,:), lblsDynTLinkage); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('Dyn T linkage'); legend off
        end

        %% Compare clustering
        tLinkageMetrics = compareClustering(G, lblsTLinkage);
        dynTLinkageMetrics = compareClustering(G, lblsDynTLinkage);
        LOFdynTLinkageMetrics = compareClustering(G, lblsLOFDynCut);

        metrics(outlierIdx, eps).tLinkage = tLinkageMetrics;
        metrics(outlierIdx, eps).dynTLinkage = dynTLinkageMetrics;
        metrics(outlierIdx, eps).LOFdynTLinkage = LOFdynTLinkageMetrics;
    end
    
    outlierIdx = outlierIdx + 1;
end  


xPlotRange =[];
xLabelValue = "";

%% Different parameter comparisons
if length(epsilonRange) > 1 || length(outlierRange) > 1
    if length(epsilonRange) > 1
        xPlotRange = epsilonRange;
        xLabelValue = "\epsilon";
        titleBasedOn = xLabelValue;
        finalTLinkageMetric = [metrics(1, :).tLinkage];
        finalDynTLinkageMetric = [metrics(1, :).dynTLinkage];
        finalLOFDynTLinkageMetric = [metrics(1, :).LOFdynTLinkage];
        imageFolder = graphsFolderImgsInlier;
        figureFolder = graphsFolderFigsInlier
    else
        xPlotRange = (outlierRange - nRealPoints)/ nRealPoints * 100;
        xLabelValue = "Outliers / real points [%]";
        titleBasedOn = "outlier presence";
        finalTLinkageMetric = [metrics(:, 1).tLinkage];
        finalDynTLinkageMetric = [metrics(:, 1).dynTLinkage];
        finalLOFDynTLinkageMetric = [metrics(:, 1).LOFdynTLinkage];
        imageFolder = graphsFolderImgsOutlier;
        figureFolder = graphsFolderFigsOutlier;
    end

%% INLIER ARI COMPARISON
    %{
    figure('name','Ari')
    plot(xPlotRange, [finalTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "o")
    hold on
    plot(xPlotRange, [finalDynTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "+")
    plot(xPlotRange, [finalLOFDynTLinkageMetric.ariScore], "-", "LineWidth", 2, ...
        "Marker", "s")
    lgd = legend("T-Link ME", "Dyn T-Link ME", "LOF Dyn T-Link");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage")
    xlabel(xLabelValue, "FontSize", 16)
    ylabel("ARI", "FontSize", 14)
    ylim([0 0.8])
    saveas(gcf, graphsFolderImgsInlier + datasetTitle + "_ARI", 'png');
    saveas(gcf, graphsFolderFigsInlier + datasetTitle + "_ARI");
    %}

    %% MISCLASS ERROR
    figure('name','Misclassification Error')
    plot(xPlotRange, [finalTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "o")
    hold on
    plot(xPlotRange, [finalDynTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "+")
    plot(xPlotRange, [finalLOFDynTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "s")
    lgd = legend("T-Link ME", "Dyn T-Link ME", "LOF Dyn T-Link");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage")
    xlabel(xLabelValue, "FontSize", 16)
    ylabel("Misclassification Error %", "FontSize", 14)
    ylim([0 0.8])
    %%%%%%%%%%%%%%%%%%%%%%% HERE
    saveas(gcf, imageFolder + datasetTitle + "_ME", 'png');
    saveas(gcf, figureFolder + datasetTitle + "_ME");

    %% INLIER THRESHOLD - PARAMETER LAMBDA 1
    figure
    plot(xPlotRange, lambda1, "s-", "LineWidth", 2, "Color", "#0072BD")
    yline(mean(lambda1), "--", mean(lambda1), "LineWidth", 2.3, "Color", "#D95319", ...
        "LabelVerticalAlignment", "Bottom", ...
        "FontSize", 15)
    title("Variation of lambda 1 parameter based on " + titleBasedOn)
    xlabel(xLabelValue, "FontSize", 16)
    ylabel("\lambda_{1}(\epsilon)", "FontSize", 16)
    legend("\lambda_{1}(\epsilon)", "FontSize", 16)
    xlim([min(xPlotRange)-0.005, max(xPlotRange)+0.005])
    ylim([0, max(lambda1)+15])
    saveas(gcf, imageFolder + datasetTitle + "_Lambda1Variation", 'png');
    saveas(gcf, figureFolder + datasetTitle + "_Lambda1Variation");


    %% INLIER THRESHOLD - PARAMETER LAMBDA 2
    figure
    plot(xPlotRange, lambda2, "s-", "LineWidth", 2, "Color", "#0072BD")
    yline(mean(lambda2), "--", mean(lambda2), "LineWidth", 2.3, "Color", "#D95319", ...
        "LabelVerticalAlignment", "Bottom", ...
        "FontSize", 15)
    title("Variation of lambda 2 parameter based on " + titleBasedOn)
    xlabel(xLabelValue, "FontSize", 16)
    ylabel("\lambda_{2}(\epsilon)", "FontSize", 16)
    legend("\lambda_{2}(\epsilon)", "FontSize", 16)
    xlim([min(xPlotRange)-0.005, max(xPlotRange)+0.005])
    ylim([0, max(lambda2)+15])
   
    saveas(gcf, imageFolder + datasetTitle + "_Lambda2Variation", 'png');
    saveas(gcf, figureFolder + datasetTitle + "_Lambda2Variation");
    
    %% Improvement Comparison - How much our algorithm impact on ME?
    
    % LOF Dynamic T-Linkage vs T-Linkage
    LOFDynVsTlnk = [finalLOFDynTLinkageMetric.misclassErr] - [finalTLinkageMetric.misclassErr];
    
    % Dynamic T-Linkage vs T-Linkage
    DynVsTlnk = [finalDynTLinkageMetric.misclassErr] - [finalTLinkageMetric.misclassErr];
    
    figure
    bar(xPlotRange, [LOFDynVsTlnk; DynVsTlnk])
    legend("LOF", "DYN", "Location", "Best", "FontSize", 14)
    title("Delta ME [LOF] Dyn T-Link vs T-Link", "FontSize", 15)
    xlabel(xLabelValue, "FontSize", 16)
    ylabel("Delta % ME", "FontSize", 15)
    %xlim([min(epsilonRange)-0.05, max(epsilonRange)+0.005])
    ylim( [ ...
        min( ...
            [LOFDynVsTlnk'; DynVsTlnk'] ...
        )-0.05, ...
        max( ...
            [LOFDynVsTlnk'; DynVsTlnk'] ...
        )+0.05 ])
    
    saveas(gcf, imageFolder + datasetTitle + "_ImprovementPerc", 'png');
    saveas(gcf, figureFolder + datasetTitle + "_ImprovementPerc");
    
end



%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it