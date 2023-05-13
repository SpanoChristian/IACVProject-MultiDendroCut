function [misclassErr, ARI, NMI, ARINMI, lambda1, lambda2, thresholds] = ...
        outlierVariationNew(model2fit, epsilon, outlierRange)

    addpath(genpath("."))

    k = 1;

    nModelsToCheck = 3;
    misclassErr = zeros(0, nModelsToCheck);
    ARI = zeros(0, nModelsToCheck);
    NMI = zeros(0, nModelsToCheck);
    ARINMI = zeros(0, nModelsToCheck);
    lambda1 = [];
    lambda2 = [];
    thresholds = [];

    labelled_data = false; 
    inliers = [];

    [distFun, hpFun, ~, cardmss, isMergeableGricModel] = set_model(model2fit);

    for i = floor(outlierRange)

        [X, G, ~, ~, ~, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);
        X = X(:, 1:i);

        N = size(X, 2);

        if ~labelled_data
            G = generateGTLbls(nClusters, 50, i-250); %#ok<UNRCH>
        end
                
        S = mssUniform(X, 5*N, cardmss);
        H = hpFun(X, S); 
        R = res(X, H, distFun);
        P = prefMat(R, epsilon, 1);

        [C, T] = tlnk(P);
        C = outlier_rejection_card( C, cardmss );
        C = orderLbls(C, 50, i);

        W = linkage_to_tree(T);
        root = W(end, 3);

        lambdaRange = 0:5:80;

        [bestLambda1, bestLambda2] = computeBestParams(root, X, W, G, C, lambdaRange, ...
           isMergeableGricModel, epsilon);

        lambda1(end+1) = bestLambda1;
        lambda2(end+1) = bestLambda2;

        [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, bestLambda1, bestLambda2, epsilon, ...
            isMergeableGricModel, false);

        best = 1;
        bestThreshold = 20;
        for clusterThreshold = 0:2.5:40
            lblsDynCut = labelsAfterDynCut(X, W, AltB, clusterThreshold, C);
            dynMetric = compareClustering(G, lblsDynCut);
            if best > dynMetric.misclassErr
                best = dynMetric.misclassErr;
                bestThreshold = clusterThreshold;
            end
        end

        thresholds(end+1) = bestThreshold;

        lblsDynCut = labelsAfterDynCut(X, W, AltB, bestThreshold, C);
        TLinkageMetric = compareClustering(G, C);  
        dynTLinkageMetric = compareClustering(G, lblsDynCut);  
        
        misclassErr(k, 1:2) = [TLinkageMetric.misclassErr dynTLinkageMetric.misclassErr];
        ARI(k, 1:2) = [TLinkageMetric.ariScore dynTLinkageMetric.ariScore];
        NMI(k, 1:2) = [TLinkageMetric.nmiScore dynTLinkageMetric.nmiScore];
        ARINMI(k, 1:2) = [TLinkageMetric.arinmiScore dynTLinkageMetric.arinmiScore];

        candidateOutliers = LOF(X');
        lblsDynCut(candidateOutliers) = 0;
        LOFMetric = compareClustering(G, lblsDynCut);

        misclassErr(k, 3) = LOFMetric.misclassErr;
        ARI(k, 3) = LOFMetric.ariScore;
        NMI(k, 3) = LOFMetric.nmiScore;
        ARINMI(k, 3) = LOFMetric.arinmiScore;

        disp([["Outlier % : " ((i-250)/250)*100 + "%"]; 
             ["T-Linkage  : " misclassErr(end, 1)];
             ["DYN T-link : " misclassErr(end, 2)];
             ["LOFDYN T   : " misclassErr(end, 3)]])

        k = k + 1;

        disp(k)
    end
end