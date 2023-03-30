addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation
load './Dataset/star5.mat';
%X = Star5_S00075_O75;
N = size(X, 2);
% In order to work with a specific model, T-Linkage needs to be given:
% - distFun: distance between points and models
% - hpFun: returns an estimate model given cardmss points
% - fit_model: least square fitting function
% 
% In this example we want to estimate lines so distFun is the euclidean
% distance between a point from a line in the plane and cardmss=2.
% Other  possible models are 'line', 'circle',
% fundamental matrices ('fundamental') and 'subspace4' (look in 'model_spec' folder).

%%
G = [];

for i = 1:5
    G = [G; i*ones(50, 1)];
end
G(end:end+250) = 0;
%%
[distFun, hpFun, fit_model, cardmss] = set_model('line');
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

epsilon = 0.07; % An inlier threshold value  epsilon has to be specified.
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
%C  = outlier_rejection_card( C, cardmss );
% Outliers are labelled by '0'
%% Showing results
figure
subplot(1,2,1); gscatter(X(1,:),X(2,:), G); axis equal; title('GroundTruth'); legend off
subplot(1,2,2); gscatter(X(1,:),X(2,:), C); axis equal; title('T linkage'); legend off
%% 
% [~, ~, stdN, confInt] = clusterNumPoints(C)
% clustStats.stdN = stdN;
% clustStats.CI = confInt;
%%
W = linkage_to_tree(T);
root = W(end, 3);

vals1 = 30:10:140;
vals2 = 10:10:140;

[bestLambda1, bestLambda2] = computeBestParams(root, X, W, ...
    G, C, vals1, vals2);

%%
[~, ~, ~, ~, AltB] = exploreBFS(root, X, W, bestLambda1, bestLambda2);
lblsDynCut = labelsAfterDynCut(X, W, AltB);
[ariScore, nmiScore] = compareClustering(G, C, lblsDynCut);
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
%%
% Find the misclassified points
misclassified_pointsTLink = find(G ~= C);
misclassified_pointsDynTLink = find(G ~= lblsDynCut);

% Calculate the misclassification error
misclassification_errorTLink = length(misclassified_pointsTLink) / length(G);
misclassification_errorDynTLink = length(misclassified_pointsDynTLink) / length(G);

% Display the misclassification error
disp(['Misclassification error T-Linkage: ' num2str(misclassification_errorTLink)]);
disp(['Misclassification error Dynamic T-Linkage: ' num2str(misclassification_errorDynTLink)]);

%% INLIER THRESHOLD COMPARISON
%load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
figure
plot(0.01:0.015:0.2, smoothdata(misclassErr(:, 1)), "-", "LineWidth", 2, ...
    "Marker", "o")
hold on
plot(0.01:0.015:0.2, smoothdata(misclassErr(:, 2)), "-", "LineWidth", 2, ...
    "Marker", "+")
lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. Dynamic T-Linkage")
xlabel("\epsilon", "FontSize", 16)
ylabel("Misclassification Error", "FontSize", 14)

%% OUTLIER PERCENTAGE COMPARISON
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
%%
figure
%load("./DendrogramUtils/Scores&Params_InlierThresholdComparison.mat")
v = 0.01:0.015:0.2;
plot(v, smoothdata(ariScore(:, 1)), "--", "LineWidth", 2, "Color", "#D95319")
hold on
plot(v, smoothdata(ariScore(:, 2)), "-", "LineWidth", 2, "Color", "#D95319")
plot(v, smoothdata(nmiScore(:, 1)), "--", "LineWidth", 2, "Color", "#0072BD")
plot(v, smoothdata(nmiScore(:, 2)), "-", "LineWidth", 2, "Color", "#0072BD")
lgd = legend("ARI T-Linkage", "ARI Dyn T-Linkage", "NMI T-Linkage", "NMI Dyn T-Linkage");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. Dynamic T-Linkage")
xlabel("\epsilon", "FontSize", 16)
ylabel("ARI & NMI", "FontSize", 14)

%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it