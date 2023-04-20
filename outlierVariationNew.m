addpath(genpath("."))

k = 0;

performance = zeros(0, 3);

labelled_data = false; 
[X, G, nTotPoints, nRealPoints, nOutliers, nClusters, ~] = getDatasetAndInfo(labelled_data, 2);

inliers = [];
H = hpFun(X, S); 
R = res(X, H, distFun);
epsilon = 0.085;
P = prefMat(R, epsilon, 1);

for i = floor(linspace(250, 500, 8))
    
    X = X(:, 1:i);
    
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
        G = generateGTLbls(nClusters, 50, i-250); %#ok<UNRCH>
    end
    
    P = prefMat(R, epsilon, 1);

    [C, T] = tlnk(P);
    C  = outlier_rejection_card( C, cardmss );
    Cnew = orderLbls(C, 50, 500);

    C = Cnew;

    W = linkage_to_tree(T);
    root = W(end, 3);

    lambdaRange = 0:5:50;

    %bestLambda = computeBestParams(root, X, W, G, C, lambdaRange, ...
     %   isMergeableGricModel, epsilon);

    [~, ~, ~, ~, AltB] = exploreDFS(root, X, W, 25, epsilon, ...
        isMergeableGricModel, false);
    lblsDynCut = labelsAfterDynCut(X, W, AltB, 20);
    [ME, ~, ~, ~] = compareClustering(G, C, lblsDynCut);  

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

outlierRange = linspace(0, 1, 10);

%% OUTLIER THRESHOLD ME COMPARISON
figure
plot(outlierRange, performance(:, 1), "-", "LineWidth", 2, ...
    "Marker", "o", "Color", "#0072BD")
hold on
plot(outlierRange, performance(:, 2), "-", "LineWidth", 2, ...
    "Marker", "+", "Color", "#D95319")
hold on
plot(outlierRange, performance(:, 3), "-", "LineWidth", 2, ...
    "Marker", "*", "Color", "#EDB120")
lgd = legend("T-Linkage ME", "Dynamic T-Linkage ME", "LOF Dynamic T-Linkage ME");
lgd.FontSize = 15; % Change the font size to 14 points
title("Comparison T-Linkage vs. [LOF] Dynamic T-Linkage (" + datasetTitle + ")")
xlabel("Outlier %", "FontSize", 16)
ylabel("Misclassification Error", "FontSize", 14)
roof = max([performance(:, 1); performance(:, 2); performance(:, 3)]);
xlim([min(outlierRange)-0.005, max(outlierRange)+0.005])
ylim([0, roof+0.15])

saveas(gcf, graphsFolderImgsOutlier + datasetTitle + "_MEComparison", 'png');
saveas(gcf, graphsFolderFigsOutlier + datasetTitle + "_MEComparison");

%%
% LOF Dynamic T-Linkage vs T-Linkage
LOFDynVsTlnk = performance(:, 1) - performance(:, 3);

% Dynamic T-Linkage vs T-Linkage
DynVsTlnk = performance(:, 1) - performance(:, 2);

figure
bar(outlierRange, [LOFDynVsTlnk'; DynVsTlnk'])
legend("LOF", "DYN", "Location", "Best", "FontSize", 14)
title("Improvement of [LOF] Dynamic T-Linkage", "FontSize", 15)
xlabel("Outlier %", "FontSize", 16)
ylabel("% ME Improved", "FontSize", 15)

saveas(gcf, graphsFolderImgsOutlier + datasetTitle + "_ImprovementPerc", 'png');
saveas(gcf, graphsFolderFigsOutlier + datasetTitle + "_ImprovementPerc");