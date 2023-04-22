close all % close all figures
addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation

showGraphs = false;

clusterSize = 50;
clusterThreshold = 0;
labelled_data = false;
[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = set_model('line');

% move generateGTLbls into getDatasetAndInfo
 if ~labelled_data
        G = generateGTLbls(nClusters, clusterSize, nOutliers); %#ok<UNRCH>
end

epsilonRange= linspace(0.02, 0.25, 30);
%epsilonRange = 0.085; % An inlier threshold value  epsilon has to be specified.


outlierRange = 0:0.05:1; % TODO to use

for i=1:length(epsilonRange)
    if length(epsilonRange) > 1
        display("Inlier threshold variation " + i + " out of " + length(epsilonRange))
    end
    
    epsilon = epsilonRange(i);
    
    %% Perform T-Linkage
    [lblsTLinkage, T] = t_linkage(X, distFun, epsilon, cardmss, hpFun);
    
    %% Perform Dynamic T-Linkage
    lblsDynTLinkage = dynamicTLinkage(X, T, G, lblsTLinkage, epsilon, isMergeableGricModel, clusterThreshold);
    
    %% Outlier rejection step
    
    %T-Linkage fit a model to all the data points. Outlier can be found in
    %different ways (T-Linkage is agonostic about the outlier rejection strategy),
    %for example discarding too small cluster, or exploiting the randomness of
    %a model.
    
    lblsTLinkage = operateOnOutliers(lblsTLinkage, cardmss);
    lblsDynTLinkage = operateOnOutliers(lblsDynTLinkage, cardmss);
    
    
    %% Order labels step
    
    lblsTLinkage = orderClusterLabels(lblsTLinkage, clusterSize);
    lblsDynTLinkage = orderClusterLabels(lblsDynTLinkage, clusterSize);
    
    %% Showing results
    if showGraphs
        figure('name','Assigned labels')
        subplot(1,3,1); gscatter(X(1,:),X(2,:), G); axis equal; title('GroundTruth'); legend off
        subplot(1,3,2); gscatter(X(1,:),X(2,:), lblsTLinkage); axis equal; title('T linkage'); legend off
        subplot(1,3,3); gscatter(X(1,:),X(2,:), lblsDynTLinkage); axis equal; title('Dyn T linkage'); legend off
    end
    
    %% Compare clustering
    
    tLinkageMetrics = compareClustering(G, lblsTLinkage);
    dynTLinkageMetrics = compareClustering(G, lblsDynTLinkage);

    metrics(i).tLinkage = tLinkageMetrics;
    metrics(i).dynTLinkage = dynTLinkageMetrics;

end

%% INLIER ARI COMPARISON
if length(epsilonRange) > 1
    finalTLinkageMetric = [metrics.tLinkage];
    finalDynTLinkageMetric = [metrics.dynTLinkage];
    figure('name','Ari')
    plot(epsilonRange, [finalTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "o")
    hold on
    plot(epsilonRange, [finalDynTLinkageMetric.misclassErr], "-", "LineWidth", 2, ...
        "Marker", "+")
    lgd = legend("T-Linkage ARI", "Dynamic T-Linkage ARI");
    lgd.FontSize = 15; % Change the font size to 14 points
    title("Comparison T-Linkage vs. LOF Dynamic T-Linkage")
    xlabel("\epsilon", "FontSize", 16)
    ylabel("ARI", "FontSize", 14)
    ylim([0 0.8])
end


%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it