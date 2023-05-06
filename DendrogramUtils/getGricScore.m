function [gScore, dataFidelity, modelComplexity] = getGricScore(Xi, ...
    sigma, lambda1, lambda2, ~)
%GETGRICSCORE the higher the worse

if size(Xi,2) >= 2
    mi = fitline(Xi);
    ri = res_line(Xi, mi);
else
    ri = 10;
end
rSqr = ri.^2;
n = numel(rSqr);

% Sum for number of rSqr element
%dataFidelity = sum(min(rSqr./sigma^2, 2));

dataFidelity = min(mean(rSqr, 'omitnan'), 100);
modelComplexity = 1/(exp(-(((n-lambda1)/(lambda2)))^(2)));
%modelComplexity = 10/(exp(-(((n-lambda1)/(lambda2)))^(2))+(1/10));
%modelComplexity = 0.1*(n - lambda)^2;
%modelComplexity = (300 * (n - lambda2)^2)/(lambda1^2 + (n - lambda2)^2);
gScore = dataFidelity + modelComplexity;

% disp([["Num Points : " n]; ...
%       ["Min Res    : " mean(rSqr)]; ...
%       ["Complexity : " modelComplexity]; ...
%       ["Fidelity   : " dataFidelity]; ...
%       ["gScore     : " gScore]])
% disp(["C/Gscore : " modelComplexity + " vs. " + dataFidelity]);

end
