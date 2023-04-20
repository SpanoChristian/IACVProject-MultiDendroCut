
N = size(X, 2);

model2fit = 'line';
[distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = ...
    set_model(model2fit);

S = mssUniform(X, 5*N, cardmss);
H = hpFun(X, S);
R = res(X, H, distFun);

for epsilon = linspace(0.05, 0.2, 10)
    P = prefMat(R, epsilon, 1);

    [C, T] = tlnk(P);
    C = outlier_rejection_card(C, cardmss);
    
    Cordered = orderClusterLabels(C, 50);
    [ls, ~] = orderLbls(C, 50, 500);

    [MEOld, ~, ~, ~] = compareClustering(G, C, Cordered);
    [MENew, ~, ~, ~] = compareClustering(G, C, ls);

    disp([["MEOld : " MEOld];
          ["MENew : " MENew]])
end


