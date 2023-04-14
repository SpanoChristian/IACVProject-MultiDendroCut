addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation

graphsFolderImgs = "Graphs/Images/";
graphsFolderFigs = "Graphs/Figures/";

epsilonRange = linspace(0.02, 0.25, 30);
outlierRange = linspace(0, 1, 30);

% If the ground truth labels are provided: true
% Otherwise: false
labelled_data = false;

model2fit = 'line';

for i=2:2

    [X,G, nTotPoints, nRealPoints, nOutliers, nClusters, datasetTitle] = getDatasetAndInfo(labelled_data, i);
  
    if ~labelled_data
        G = generateGTLbls(nClusters, 50, nOutliers); %#ok<UNRCH>
    end
  
    [misclassErr, ARI, NMI, ARINMI, lambda, thresholds] = ...
        inlierThresholdComparison(X, G, epsilonRange, model2fit);

    %% 
%     figure
%     subplot(1, 3, 1)
%     gscatter(X(1,:), X(2,:), G); axis square; title('GroundTruth');
%     
%     subplot(1, 3, 2)
%     gscatter(X(1,:), X(2,:), C); axis square; title('T-Linkage');
%     
%     subplot(1, 3, 3)
%     gscatter(X(1,:), X(2,:), lblsDynCut); axis square; title('T linkage w/ Dynamic Cut');
%     
%     saveas(gcf, graphsFolder + datasetTitle + "_ClusterData", 'png');
%     saveas(gcf, graphsFolder + datasetTitle + "_ClusterData");

    %% INLIER THRESHOLD ME COMPARISON
    %load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
    figure
    plot(epsilonRange, misclassErr(:, 1), "-", "LineWidth", 2, ...
        "Marker", "o", "Color", "#0072BD")
    hold on
    plot(epsilonRange, misclassErr(:, 2), "-", "LineWidth", 2, ...
        "Marker", "+", "Color", "#D95319")
    hold on
    plot(epsilonRange, misclassErr(:, 3), "-", "LineWidth", 2, ...
        "Marker", "*", "Color", "#EDB120")
    lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME", "LOF Dynamic T-Linkage ME");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage (" + datasetTitle + ")")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("Misclassification Error", "FontSize", 14)
    roof = max([misclassErr(:, 1); misclassErr(:, 2); misclassErr(:, 3)]);
    xlim([min(epsilonRange)-0.02, max(epsilonRange)+0.02])
    ylim([0, roof+0.1])

    saveas(gcf, graphsFolderImgs + datasetTitle + "_MEComparison", 'png');
    saveas(gcf, graphsFolderFigs + datasetTitle + "_MEComparison");
  
    %% INLIER THRESHOLD - PARAMETER LAMBDA
    figure
    plot(epsilonRange, lambda, "s-", "LineWidth", 2, "Color", "#0072BD")
    yline(mean(lambda), "--", mean(lambda), "LineWidth", 2.3, "Color", "#D95319", ...
        "LabelVerticalAlignment", "Bottom", ...
        "FontSize", 15)
    title("Variation of lambda parameter based on \epsilon")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("\lambda(\epsilon)", "FontSize", 16)
    legend("\lambda(\epsilon)", "FontSize", 16)
    xlim([min(epsilonRange)-0.02, max(epsilonRange)+0.02])
    ylim([0, max(lambda)+10])
   
    saveas(gcf, graphsFolderImgs + datasetTitle + "_LambdaVariation", 'png');
    saveas(gcf, graphsFolderFigs + datasetTitle + "_LambdaVariation");
    
    %% Improvement Comparison - How much our algorithm impact on ME?
    
    % LOF Dynamic T-Linkage vs T-Linkage
    LOFDynVsTlnk = misclassErr(:, 1) - misclassErr(:, 3);
    
    % Dynamic T-Linkage vs T-Linkage
    DynVsTlnk = misclassErr(:, 1) - misclassErr(:, 2);
    
    bar(epsilonRange, [LOFDynVsTlnk'; DynVsTlnk'])
    legend("LOF", "DYN", "Location", "Best", "FontSize", 14)
    title("Improvement of [LOF] Dynamic T-Linkage", "FontSize", 15)
    xlabel("\epsilon", "FontSize", 16)
    ylabel("% ME Improved", "FontSize", 15)
    
    saveas(gcf, graphsFolderImgs + datasetTitle + "_ImprovementPerc", 'png');
    saveas(gcf, graphsFolderFigs + datasetTitle + "_ImprovementPerc");
    %% INLIER THRESHOLD COMPARISON - ARI & NMI
%     figure
%     %load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
%     v = 0.005:0.0075:0.2;
%     plot(v, ARI(:, 1), "o--", "LineWidth", 2, "Color", "#D95319")
%     hold on
%     plot(v, ARI(:, 2), "s-", "LineWidth", 2, "Color", "#0072BD")
%     % plot(v, smoothdata(nmiScore(:, 1)), "--", "LineWidth", 2, "Color", "#0072BD")
%     % plot(v, smoothdata(nmiScore(:, 2)), "-", "LineWidth", 2, "Color", "#0072BD")
%     lgd = legend("T-Linkage ARI \times NMI", "LOF Dynamic T-Linkage ARI \times NMI");
%     lgd.FontSize = 15; % Change the font size to 14 points
%     title("Comparison T-Linkage vs. LOF Dynamic T-Linkage")
%     xlabel("\epsilon", "FontSize", 16)
%     ylabel("ARI \times NMI", "FontSize", 14)
end