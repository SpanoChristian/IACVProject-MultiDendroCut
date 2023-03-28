function [gScore, dataFidelity, modelComplexity] = getGricScore(rSqr,sigma,r,d,k,lambda1, lambda2)
%GETGRICSCORE 
% k number of parameters;
% d dimension of the manifold
% r dimension of the space

n = numel(rSqr);

dataFidelity = sum(min(rSqr./sigma^2, 2));
modelComplexity = 1/(exp(-(((n-75)/(40)))^(2)));
gScore = dataFidelity + modelComplexity;

disp([["Num Points : " n]; ...
      ["Min Res    : " min(1/100*rSqr./sigma^2)]; ...
      ["Complexity : " modelComplexity]; ...
      ["Fidelity   : " dataFidelity]; ...
      ["gScore     : " gScore]])

end


