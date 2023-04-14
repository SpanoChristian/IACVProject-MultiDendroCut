addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation

graphsFolder = "Graphs/";
epsilonRange = 0.02:0.005:0.2;

% If the ground truth labels are provided: true
% Otherwise: false
labelled_data = false;

for i=2:2

    [X,G, nTotPoints, nRealPoints, nOutliers, nClusters, datasetTitle] = getDatasetAndInfo(labelled_data, i);
  
    if ~labelled_data
        G = generateGTLbls(nClusters, 50, nOutliers); %#ok<UNRCH>
    end
  
    [misclassErr, ARI, NMI, ARINMI, l1, l2] = inlierThresholdComparison(X, G, epsilonRange);

    
%     subplot(1, 3, 1)
%     gscatter(X(1,:), X(2,:), G); axis square; title('GroundTruth');
%     
%     subplot(1, 3, 2)
%     gscatter(X(1,:), X(2,:), C); axis square; title('T linkage');
%     
%     subplot(1, 3, 3)
%     gscatter(X(1,:), X(2,:), lblsDynCut); axis square; title('T linkage w/ Dynamic Cut');

    %% INLIER and OUTLIER RANGE
    outlierRange = 0:0.5:1;
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
    ylim([0 0.8])

    saveas(gcf, graphsFolder + datasetTitle + "_MEComparison", 'png');
    saveas(gcf, graphsFolder + datasetTitle + "_MEComparison");
   

    %% INLIER THRESHOLD - PARAMETER LAMBDA
    figure
    plot(epsilonRange, l2, "s-", "LineWidth", 2, "Color", "#0072BD")
    yline(mean(l2), "--", mean(l2), "LineWidth", 2.3, "Color", "#D95319", ...
        "LabelVerticalAlignment", "Bottom", ...
        "FontSize", 15)
    title("Variation of lambda parameter based on \epsilon")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("\lambda(\epsilon)", "FontSize", 16)
    legend("\lambda(\epsilon)", "FontSize", 16)
    ylim([0, 60])
   
    saveas(gcf, graphsFolder + datasetTitle + "_LambdaVariation", 'png');
    saveas(gcf, graphsFolder + datasetTitle + "_LambdaVariation");
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

%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it