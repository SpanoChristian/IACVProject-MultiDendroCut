function [gScore, dataFidelity, modelComplexity] = getGricScore(rSqr, ...
    sigma, lambda)
%GETGRICSCORE the higher the worse

n = numel(rSqr);
% stdN = clustStats.stdN;
% confInt = clustStats.CI;
% meanN = round(mean(confInt));

% Sum for number of rSqr element
%dataFidelity = sum(min(rSqr./sigma^2, 2));

dataFidelity = min(mean(rSqr, 'omitnan'), 50);
%modelComplexity = 1/(exp(-(((n-lambda1)/(lambda2)))^(2)));
%modelComplexity = 10/(exp(-(((n-lambda1)/(lambda2)))^(2))+(1/10));
modelComplexity = (n - lambda)^2;
gScore = dataFidelity + modelComplexity;

% disp([["Num Points : " n]; ...
%       ["Min Res    : " mean(rSqr)]; ...
%       ["Complexity : " modelComplexity]; ...
%       ["Fidelity   : " dataFidelity]; ...
%       ["gScore     : " gScore]])
% disp(["C/Gscore : " modelComplexity + " vs. " + dataFidelity]);

end


