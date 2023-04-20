addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation

% If the ground truth labels are provided: true
% Otherwise: false
labelled_data = false;

[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);

N = size(X, 2);
% In order to work with a specific model, T-Linkage needs to be given:
% - distFun: distance between points and models
% - hpFun: returns an estimate model given cardmss points
% - fit_model: least square fitting function


% In this example we want to estimate lines so distFun is the euclidean
% distance between a point from a line in the plane and cardmss=2.
% Other  possible models are 'line', 'circle',
% fundamental matrices ('fundamental') and 'subspace4' (look in 'model_spec' folder).

if ~labelled_data
    G = generateGTLbls(nClusters, 50, 250); %#ok<UNRCH>
end

[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = set_model('line');
%% Conceptual representation of points

%T-linkage starts, as Ransac with random sampling:
% Unform sampling can be adopted
S = mssUniform(X, 5*N, cardmss);
% in order to reduce the number of hypotheses also a localized sampling can
% be used:
%
%       D = pdist(X','euclidean');  D = squareform(D);
%       S = mssNorm( X, D, 2*N, cardmss);
%

H = hpFun(X, S); 
% generating a pool of putative hypotheses H.
% The residuals R between points and model
R = res(X, H, distFun);
% are used for representing points in a conceptual space.
% In particular a preference matrix P is built depicting by rows points
% preferences.
% 

epsilon = 0.12; % An inlier threshold value  epsilon has to be specified.
P = prefMat(R, epsilon, 1);

%% Clustering

%T-Linkage clustering follow a bottom up scheme in the preference space

[C, T] = tlnk(P);

% C is a vector of labels, points belonging to the same models share the
% same label.
%% Outlier rejection step

%T-Linkage fit a model to all the data points. Outlier can be found in
%different ways (T-Linkage is agonostic about the outlier rejection strategy),
%for example discarding too small cluster, or exploiting the randomness of
%a model.

% uncomment only if we don't change resulting labels
C  = outlier_rejection_card( C, cardmss );
Cnew = orderClusterLabels(C, 50);
% Cnew(Cnew == max(Cnew)) = 0;
C = Cnew;

% Outliers are labelled by '0'
%% Showing results
figure
subplot(1,2,1); gscatter(X(1,:),X(2,:), G); axis equal; title('GroundTruth'); legend off
subplot(1,2,2); gscatter(X(1,:),X(2,:), C); axis equal; title('T linkage'); legend off
%%
[~, meanN, stdN, confInt] = clusterNumPoints(C)
clustStats.stdN = stdN;
clustStats.CI = confInt;
%%
W = linkage_to_tree(T);
root = W(end, 3);

lambdaRange = 0:5:50;

bestLambda = computeBestParams(root, X, W, G, C, lambdaRange, ...
    isMergeableGricModel, epsilon);
%%
[~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda, epsilon, ...
    isMergeableGricModel, false);
lblsDynCut = labelsAfterDynCut(X, W, AltB, 20);
[ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
%%
figure

xlim([-1 1])
ylim([-1 1])

subplot(1, 3, 1)
gscatter(X(1,:), X(2,:), G); axis square; title('GroundTruth')

subplot(1, 3, 2)
gscatter(X(1,:), X(2,:), C); axis square; title('T linkage');

subplot(1, 3, 3)
gscatter(X(1,:), X(2,:), lblsDynCut); axis square; title('T linkage w/ Dynamic Cut');

%%
candidateOutliers = outliersNeighbour(X');
lblsDynCut(candidateOutliers) = 0;
[ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
%% ARI & NMI SCORE COMPARISON
ariScore
nmiScore
%% MISCLASSIFICATION ERROR COMPARISON
% Find the misclassified points
misclassified_pointsTLink = find(G ~= C);
misclassified_pointsDynTLink = find(G ~= lblsDynCut);

% Calculate the misclassification error
misclassification_errorTLink = length(misclassified_pointsTLink) / length(G);
misclassification_errorDynTLink = length(misclassified_pointsDynTLink) / length(G);

% Display the misclassification error
disp(['Misclassification error T-Linkage: ' num2str(misclassification_errorTLink)]);
disp(['Misclassification error Dynamic T-Linkage: ' num2str(misclassification_errorDynTLink)]);

%% INLIER and OUTLIER RANGE
inlierRange = 0.005:0.0075:0.2;
outlierRange = 0:0.05:1;
%% INLIER THRESHOLD COMPARISON
%load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
figure
plot(inlierRange, misclassErr(:, 1), "-", "LineWidth", 2, ...
    "Marker", "o")
hold on
plot(inlierRange, misclassErr(:, 2), "-", "LineWidth", 2, ...
    "Marker", "+")
lgd = legend("T-Linkage ME", "LOF Dynamic T-Linkage ME");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. LOF Dynamic T-Linkage")
xlabel("\epsilon", "FontSize", 16)
ylabel("Misclassification Error", "FontSize", 14)
ylim([0 0.8])
%% OUTLIER THRESHOLD - PARAMETER LAMBDA
figure
plot(outlierRange, Outl2, "s-", "LineWidth", 2, "Color", "#0072BD")
yline(mean(Outl2), "--", mean(Outl2), "LineWidth", 2.3, "Color", "#D95319", ...
    "LabelVerticalAlignment", "Bottom", ...
    "FontSize", 15)
title("Variation of lambda parameter based on outlier %")
xlabel("Outlier %", "FontSize", 16)
ylabel("\lambda(Outlier %)", "FontSize", 16)
legend("\lambda(Outlier %)", "FontSize", 16)
ylim([0, 60])
% hold on
% p = polyfit(inlierRange(3:end), l2(3:end), 2);
% yfit = polyval(p, inlierRange(3:end));
% plot(inlierRange(3:end), yfit, "-", "LineWidth", 2, "Color", "#D95319")
%% OUTLIER PERCENTAGE COMPARISON - ME
figure
plot(0:0.10:1, misclassErr(:, 1), "-", "LineWidth", 2, ...
    "Marker", "o")
hold on
plot(0:0.10:1, misclassErr(:, 2), "-", "LineWidth", 2, ...
    "Marker", "+")
lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. Dynamic T-Linkage")
xlabel("Outlier %", "FontSize", 14)
ylabel("Misclassification Error", "FontSize", 14)
ylim([0, 0.4])

%% OUTLIER PERCENTAGE COMPARISON - ME
figure
plot(0:0.05:1, OutmisclassErr(:, 1), "-", "LineWidth", 2, ...
    "Marker", "o")
hold on
plot(0:0.05:1, OutmisclassErr(:, 2), "-", "LineWidth", 2, ...
    "Marker", "+")
lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. Dynamic T-Linkage")
xlabel("Outlier %", "FontSize", 14)
ylabel("Misclassification Error", "FontSize", 14)
ylim([0, 0.5])
%% OUTLIER PERCENTAGE COMPARISON - ARI & NMI
figure
%load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
v = 0:0.05:1;
plot(v, OutARIscore(:, 1), "o--", "LineWidth", 2, "Color", "#D95319")
hold on
plot(v, OutARIscore(:, 2), "s-", "LineWidth", 2, "Color", "#0072BD")
% plot(v, OutNMIscore(:, 1), "--", "LineWidth", 2, "Color", "#0072BD")
% plot(v, OutNMIscore(:, 2), "-", "LineWidth", 2, "Color", "#0072BD")
lgd = legend("T-Linkage ARI", "LOF Dynamic T-Linkage ARI");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. LOF Dynamic T-Linkage")
xlabel("Outlier %", "FontSize", 16)
ylabel("ARI", "FontSize", 14)
ylim([0 1])
%% INLIER THRESHOLD COMPARISON - ARI & NMI
figure
%load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
v = 0.005:0.0075:0.2;
plot(v, ARI(:, 1), "o--", "LineWidth", 2, "Color", "#D95319")
hold on
plot(v, ARI(:, 2), "s-", "LineWidth", 2, "Color", "#0072BD")
% plot(v, smoothdata(nmiScore(:, 1)), "--", "LineWidth", 2, "Color", "#0072BD")
% plot(v, smoothdata(nmiScore(:, 2)), "-", "LineWidth", 2, "Color", "#0072BD")
lgd = legend("T-Linkage ARI \times NMI", "LOF Dynamic T-Linkage ARI \times NMI");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. LOF Dynamic T-Linkage")
xlabel("\epsilon", "FontSize", 16)
ylabel("ARI \times NMI", "FontSize", 14)

%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it