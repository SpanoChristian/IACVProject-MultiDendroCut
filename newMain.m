close all
addpath(genpath('.'));
plotBoundaries = 1.1;
coefficients = [-3 -0.5 0 3];
q = [1 0.7 0.6 0.2];
pointsPerCluster= [0 50 50 50];
toKeepClusters = find(pointsPerCluster ~= 0);
coefficients = coefficients(toKeepClusters);
q = q(toKeepClusters);
pointsPerCluster = pointsPerCluster(toKeepClusters);
figure
hold on
X = zeros(2, sum(pointsPerCluster));

pathname= "Graphs/Images/";
filename = length(pointsPerCluster);

for i = 1:length(pointsPerCluster)
    filename = filename + "_" + pointsPerCluster(i);
    range = (1 + sum(pointsPerCluster(1:(i - 1)))):(sum(pointsPerCluster(1:i)));
    X(1, range) = (rand(1,pointsPerCluster(i)) - 0.5)*2;
    X(2, range) = coefficients(i) .* X(1, range) + q(i);
end
X(2, :) = X(2, :) / max(X(2, :));
%{
for i = 1:length(coefficients)
    range = (1 + (i-1) * pointsPerCluster(i)):(i * pointsPerCluster(i));
    scatter(X(1,range), X(2,range));
end
%}
clusterSize = 10;
clusterThreshold = 25;
labelled_data = false;
numTotPoints = length(X);
nRealPoints = numTotPoints;
nOutliers = 0;
numToClusterizePoints = numTotPoints;    
nClusters = length(pointsPerCluster);
datasetTitle ="Lines3_15_O0";
%pointsPerCluster = numTotPoints / nClusters;
G = generateGTLbls(nClusters, pointsPerCluster, nOutliers);
gscatter(X(1,:), X(2,:), G)
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = set_model('line');

epsilonRange = 0.12; % An inlier threshold value epsilon has to be specified.

outlierRange = length(X); % consider all points

lambda1 = [];
lambda2 = [];
bestThresholds = [];

epsilon = epsilonRange(1);


%% Perform T-Linkage
[lblsTLinkage, T] = t_linkage(X, distFun, epsilon, cardmss, hpFun);

tree = linkage_to_tree(T);
if length(epsilonRange) == -1
    printBranches(tree, X, max(tree(end,3)));
end

root = tree(end, 3);

%%
[~, ~, ~, ~, toMergeClusters] = exploreDFS(root, X, tree, epsilon, ...
    isMergeableGricModel, nClusters, false);
lblsDynTLinkage = labelsAfterDynCut(X, tree, toMergeClusters, bestThresholds);

%% Outlier rejection step

%T-Linkage fit a model to all the data points. Outlier can be found in
%different ways (T-Linkage is agonostic about the outlier rejection strategy),
%for example discarding too small cluster, or exploiting the randomness of
%a model.

lblsTLinkage = operateOnOutliers(lblsTLinkage, cardmss);
%lblsDynTLinkage = operateOnOutliers(lblsDynTLinkage, cardmss);


%% Order labels step
lblsTLinkage = orderClusterLabels(lblsTLinkage, pointsPerCluster);
%lblsDynTLinkage = orderClusterLabels(lblsDynTLinkage, pointsPerCluster);

candidateOutliers = LOF(X');
lblsLOFDynCut = lblsDynTLinkage;
lblsLOFDynCut(candidateOutliers) = 0;

%% Showing results
if length(epsilonRange) == 1 && length(outlierRange) == 1
    nClustersTL = length(unique(lblsTLinkage));
    nClustersDTL = length(unique(lblsDynTLinkage));
    
    figure('name','Assigned labels')
    %s = subplot(1,3,1); gscatter(X(1,:),X(2,:), G); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title('GroundTruth'); legend off
    s = subplot(1,2,1); gscatter(X(1,:),X(2,:), lblsTLinkage); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title("T linkage (" + nClustersTL + ")"); legend off
    s = subplot(1,2,2); gscatter(X(1,:),X(2,:), lblsDynTLinkage); axis(s, 'equal'); xlim(s, [-plotBoundaries plotBoundaries]); ylim(s, [-plotBoundaries plotBoundaries]); title("Dyn T linkage (" + nClustersDTL + ")"); legend off
    
    saveas(gcf, pathname + filename, 'png');
end

%% Compare clustering
tLinkageMetrics = compareClustering(G, lblsTLinkage)
dynTLinkageMetrics = compareClustering(G, lblsDynTLinkage)
%LOFdynTLinkageMetrics = compareClustering(G, lblsLOFDynCut);

%metrics(outlierIdx, eps).tLinkage = tLinkageMetrics;
%metrics(outlierIdx, eps).dynTLinkage = dynTLinkageMetrics;