labelled_data = false;

k = 0;
performance = zeros(0, 3);

for epsilon = linspace(0.02, 0.25, 10)

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
    Cnew = orderLbls(C, 50, 500);
    % Cnew(Cnew == max(Cnew)) = 0;
    C = Cnew;

    % Outliers are labelled by '0'
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
   
    performance(k+1, 1:2) = ME;
    
    candidateOutliers = outliersNeighbour(X');
    lblsDynCut(candidateOutliers) = 0;
    [ME, ariScore, nmiScore, arinmiScore] = compareClustering(G, C, lblsDynCut);

    performance(k+1, 3) = ME(1, 2);

    disp([["Epsilon   : " epsilon]; 
         ["T-Linkage  : " performance(end, 1)];
         ["DYN T-link : " performance(end, 2)];
         ["LOFDYN T   : " performance(end, 3)]])
     
    k = k + 1;
    
    disp(k)
    
end