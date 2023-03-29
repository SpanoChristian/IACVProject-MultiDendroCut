addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation
load './Dataset/Star5.mat';
% X = X';
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

epsilon = 0.85e-1; % An inlier threshold value  epsilon has to be specified.
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
C  = outlier_rejection_card( C, cardmss );
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
[~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda1, bestLambda2);
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
% Find the misclassified points
misclassified_points = find(G ~= lblsDynCut);

% Calculate the misclassification error
misclassification_error = length(misclassified_points) / length(G);

% Display the misclassification error
disp(['Misclassification error: ' num2str(misclassification_error)]);

%%
figure
plot(0.01:0.015:0.2, misclassErr(:, 1), "-", "LineWidth", 2, ...
    "Marker", "o")
hold on
plot(0.01:0.015:0.2, misclassErr(:, 2), "-", "LineWidth", 2, ...
    "Marker", "+")
lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. Dynamic T-Linkage")
xlabel("\epsilon", "FontSize", 15)
ylabel("Misclassification Error", "FontSize", 14)

%%
figure
load("./DendrogramUtils/Scores&Params.mat")
plot(0.1e-1:0.25e-1:4.86, smoothdata(ariScore(:, 1)), "--", "LineWidth", 2)
hold on
plot(0.1e-1:0.25e-1:4.86, smoothdata(ariScore(:, 2)), "-", "LineWidth", 2)
plot(0.1e-1:0.25e-1:4.86, smoothdata(nmiScore(:, 1)), "--", "LineWidth", 2)
plot(0.1e-1:0.25e-1:4.86, smoothdata(nmiScore(:, 2)), "-", "LineWidth", 2)
lgd = legend("ARI T-Linkage", "ARI Dyn T-Linkage", "NMI T-Linkage", "NMI Dyn T-Linkage");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. Dynamic T-Linkage")
xlabel("\epsilon", "FontSize", 15)
ylabel("ARI & NMI", "FontSize", 14)

%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it