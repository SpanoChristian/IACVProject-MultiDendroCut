function [gScore, dataFidelity, modelComplexity] = getGricScore(rSqr, sigma, lambda1, lambda2)
%GETGRICSCORE 
% k number of parameters;
% d dimension of the manifold
% r dimension of the space

n = numel(rSqr);
% stdN = clustStats.stdN;
% confInt = clustStats.CI;
% meanN = round(mean(confInt));

dataFidelity = sum(min(rSqr./sigma^2, 2));
modelComplexity = 1/(exp(-(((n-lambda1)/(lambda2)))^(2)));
%modelComplexity = 100/(1 + 100*(exp(-(((n-lambda1)/(lambda2)))^(2))));
gScore = dataFidelity + modelComplexity;

% disp([["Num Points : " n]; ...
%       ["Min Res    : " min(rSqr./sigma^2)]; ...
%       ["Complexity : " modelComplexity]; ...
%       ["Fidelity   : " dataFidelity]; ...
%       ["gScore     : " gScore]])

end


