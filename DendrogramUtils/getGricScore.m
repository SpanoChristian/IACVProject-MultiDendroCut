function [gScore, dataFidelity, modelComplexity] = getGricScore(rSqr, ...
    sigma, k, nC, weight)
%GETGRICSCORE the higher the worse
% k : target number of clusters
% nC : number of clusters found so far

n = numel(rSqr);
% stdN = clustStats.stdN;
% confInt = clustStats.CI;
% meanN = round(mean(confInt));

% Sum for number of rSqr element
%dataFidelity = sum(min(rSqr./sigma^2, 2));

dataFidelity = min(mean(rSqr./sigma, 'omitnan'), 1);
%modelComplexity = 1/(exp(-(((n-lambda1)/(lambda2)))^(2)));
%modelComplexity = 10/(exp(-(((n-lambda1)/(lambda2)))^(2))+(1/10));
%modelComplexity = (n - lambda)^2;
modelComplexity = weight*abs(k - nC);

% Rationale: hav
gScore = dataFidelity*(1/(n+1)) + modelComplexity;


disp([["C found    : " nC]; ...
      ["Min Res    : " mean(rSqr)]; ...
      ["Complexity : " modelComplexity]; ...
      ["Fidelity   : " dataFidelity]; ...
      ["gScore     : " gScore]])
disp(["C/Gscore : " modelComplexity + " vs. " + dataFidelity]);

end

