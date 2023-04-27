addpath(genpath('.'));
%% Import Dataset & Useful Variables
labelled_data = false;
datasetID = 2;

[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, datasetName] = ...
    getDatasetAndInfo(labelled_data, datasetID);

figure
gscatter(X(1,:), X(2,:), G); axis equal; 
title(datasetName); legend off
%% Initialization
N = size(X, 2);

model2fit = 'line';
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = ...
    set_model(model2fit);

S = mssUniform(X, 5*N, cardmss);
H = hpFun(X, S);
R = res(X, H, distFun);

epsilon = 0.085;
P = prefMat(R, epsilon, 1);

%% Clustering
[C, T] = tlnk(P);
C = outlier_rejection_card(C, cardmss);
%% Plotting Clustering
figure
subplot(1,4,1); gscatter(X(1,:), X(2,:), G); axis square; title('Ground Truth'); legend off
subplot(1,4,2); gscatter(X(1,:), X(2,:), C); axis square; title('T-Linkage'); legend off
%Cordered = orderClusterLabels(C, 50);
[ls, ~] = orderLbls(C, 50, 400);
subplot(1,4,3); gscatter(X(1,:), X(2,:), ls); axis square; title('T-Linkage New Order'); legend off
%subplot(1,4,4); gscatter(X(1,:), X(2,:), Cordered); axis square; title('T-Linkage Old Order'); legend off
%% Performance's evaluation of T-Linkage
%[MEOld, ~, ~, ~] = compareClustering(G, C, Cordered)
[MENew, ~, ~, ~] = compareClustering(G, C, ls)
%%
W = linkage_to_tree(T);
root = W(end, 3);

lambdaRange = 0:5:50;

[bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, ls, lambdaRange, ...
    isMergeableGricModel, epsilon);
%%
[~, ~, ~, ~, AltB] = exploreBFS(root, X, W, bestLambda1, bestLambda2, epsilon, ...
    isMergeableGricModel, false);
lblsDynCut = labelsAfterDynCut(X, W, AltB, 19, ls);
[ME, ~, ~, ~] = compareClustering(G, ls, lblsDynCut)
%%
%
% bestME = 1;
% bestL = 0;
%
% for lambda = 0:10:150
%     [~, ~, ~, ~, AltB] = exploreBFS(root, X, W, lambda, epsilon, ...
%         isMergeableGricModel, false);
%     lblsDynCut = labelsAfterDynCut(X, W, AltB, 20, ls);
%     [ME, ~, ~, ~] = compareClustering(G, ls, lblsDynCut)
%     
%     if ME(1, 2) < bestME
%         bestME = ME(1, 2);
%         bestL = lambda;
%     end
% end
%%
