function [misclassErr, ARI, NMI, ARINMI, lambda1, lambda2, thresholds] = ...
    twoLambdaMain(X, G, epsilonRange, model2fit)

labelled_data = false;

k = 1;

nModelsToCheck = 3;
misclassErr = zeros(0, nModelsToCheck);
ARI = zeros(0, nModelsToCheck);
NMI = zeros(0, nModelsToCheck);
ARINMI = zeros(0, nModelsToCheck);
lambda1 = [];
lambda2 = [];

N = size(X, 2);

[distFun, hpFun, ~, cardmss, isMergeableGricModel] = set_model(model2fit);
S = mssUniform(X, 5*N, cardmss);
H = hpFun(X, S); 
R = res(X, H, distFun);

thresholds = [];

for epsilon = epsilonRange

	% TODO use tLinkage and dynTLinkage functions
    tic
    
    P = prefMat(R, epsilon, 1);
    [C, T] = tlnk(P);
    C  = outlier_rejection_card( C, cardmss );
    Cnew = orderLbls(C, 50, 500);
    C = Cnew;
    
    %%
    W = linkage_to_tree(T);
    root = W(end, 3);

    lambdaRange = 0:5:80;

    [lambda1, lambda2] = computeBestParams(root, X, W, G, C, lambdaRange, ...
        isMergeableGricModel, epsilon);
    
    lambda1(end+1) = bestLambda1;
    lambda2(end+1) = bestLambda2;
    %%
    [~, ~, ~, ~, AltB] = exploreBFS(root, X, W, bestLambda1, bestLambda2, epsilon, ...
        isMergeableGricModel, false);
    
    best = 1;
    bestThreshold = 20;
    lblsDynCutBest = [];
    for clusterThreshold = 0:2.5:40
        lblsDynCut = labelsAfterDynCut(X, W, AltB, clusterThreshold);
        [ME, ~, ~, ~] = compareClustering(G, C, lblsDynCut);
        if best > ME(1, 2)
            best = ME(1, 2);
            bestThreshold = clusterThreshold;
            lblsDynCutBest = lblsDynCut;
        end
    end

    thresholds(end+1) = bestThreshold;
    
    lblsDynCut = labelsAfterDynCut(X, W, AltB, bestThreshold, C);
    [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
   
    misclassErr(k, 1:2) = ME;
    ARI(k, 1:2) = ariScore;
    NMI(k, 1:2) = nmiScore;
    ARINMI(k, 1:2) = arinmiScore;
    
    candidateOutliers = outliersNeighbour(X');
    lblsDynCut(candidateOutliers) = 0;
    [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);
    
    misclassErr(k, 3) = ME(1,2);
    ARI(k, 3) = ariScore(1,2);
    NMI(k, 3) = nmiScore(1,2);
    ARINMI(k, 3) = arinmiScore(1,2);

    disp([["Epsilon   : " epsilon]; 
         ["T-Linkage  : " misclassErr(end, 1)];
         ["DYN T-link : " misclassErr(end, 2)];
         ["LOFDYN T   : " misclassErr(end, 3)]])
     
    k = k + 1;
    
    elapsed_time = toc;
    fprintf('Iteration %d took %f seconds\n', k, elapsed_time);
    
end