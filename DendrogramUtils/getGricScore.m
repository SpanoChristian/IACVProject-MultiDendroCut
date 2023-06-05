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

modelComplexity = (1/(k^(6-k)))*weight*abs(k - nC);

dataFidelity = min(mean(rSqr./sigma, 'omitnan'), 1);
dataFidelity = dataFidelity * 1/(log(n)^(1/k));
%modelComplexity = (1/(n + 1)) * modelComplexity;


% Rationale: hav
gScore = dataFidelity + modelComplexity;


assert(gScore == dataFidelity + modelComplexity, 'not matching in getGricScore')

%{
disp([["C found    : " nC]; ...
      ["Min Res    : " mean(rSqr)]; ...
      ["Complexity : " modelComplexity]; ...
      ["Fidelity   : " dataFidelity]; ...
      ["gScore     : " gScore]])
disp(["C/Gscore : " modelComplexity + " vs. " + dataFidelity]);
%}
end

