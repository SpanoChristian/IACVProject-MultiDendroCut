performance = zeros(0, 0);

addpath(genpath('.'));

%% Import Dataset & Useful Variables
labelled_data = false;
datasetID = 2;

[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, datasetName] = ...
    getDatasetAndInfo(labelled_data, datasetID);

%% Initialization
N = size(X, 2);

model2fit = 'line';
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = ...
    set_model(model2fit);

S = mssUniform(X, 5*N, cardmss);
H = hpFun(X, S);
R = res(X, H, distFun);
epsilon = 0.07;
P = prefMat(R, epsilon, 1);

for j = 1:10

    %% Clustering
    [C, T] = tlnk(P);
    C = outlier_rejection_card(C, cardmss);
    
    %% Performance's evaluation of T-Linkage
    %[MEOld, ~, ~, ~] = compareClustering(G, C, Cordered)
    [MENew, ~, ~, ~] = compareClustering(G, C, ls);
    
    performance(j, 1) = MENew(1, 2);
    %%
    W = linkage_to_tree(T);
    root = W(end, 3);

    lambdaRange = 0:5:50;

    [bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, ls, lambdaRange, ...
        isMergeableGricModel, epsilon);
    %%
    [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda1, bestLambda2, epsilon, ...
        isMergeableGricModel, false);
    lblsDynCut = labelsAfterDynCut(X, W, AltB, 15, ls);
    [ME, ~, ~, ~] = compareClustering(G, ls, lblsDynCut);
    
    performance(j, 2) = ME(1, 2)
end
%%
figure
plot(1:10, [performance(:, 1) performance(:, 2)])