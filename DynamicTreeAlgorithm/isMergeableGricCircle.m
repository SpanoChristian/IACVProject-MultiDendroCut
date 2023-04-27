<<<<<<< HEAD:DendrogramUtils/isMergeableGricLine.m
function [ok, msScore, msOutput] = isMergeableGricLine(X, XL, XR, lambda1, lambda2, sigma)
=======
function [ok, msScore, msOutput] = isMergeableGricCircle(X, XL, XR, lambda1, sigma, totalNumPoints)
>>>>>>> origin/comments:DynamicTreeAlgorithm/isMergeableGricCircle.m
% Check if two clusters A and B can be merged.
% The test performs the following steps:
% i) a model i on the first cluster is computed
% iia) a model j in the second cluster is computed
% iib) a model ij on the union of the cluster is computed
% iii) the old gric score on i and j is compared against the new girc score of ij
% A cluster is mergeable if the gric after the merge is lower than before
% If clusters can be merged ok = true; otherwise ok = false;
%
%  Input:
%   - X: points vector
%   - L: vector of clusters labels
%   - i and j: index of points belonging to the cluster to be merged
%   -  lambda1, lambda2 gric parameters
%  Output:
%   - ok: tells if the cluster can be merged
%   - gBefore: gric score before the merge
%   - gAfter: gric score after the merge
%   - mi model fitted on the cluster of i
%   - mj model fitted on the cluster of j
%   - mij model fitted on the union of the cluster of i and j

%%------------------------------------------------------------
% gric magic numbers for line
% cfr Torr for reference
% k = 2; % number of parameters
% d = 1; % dimension of the manifold
% r = 2; % dimenson of the ambient space
%%------------------------------------------------------------

%% precomputations

% consider points in cluster Ci, in cluster Cj and in the union Ci U Cj
Xi = XL;
Xj = XR;
Xij = X;
% fit a model on Ci, Cj and Ci U Cj
if size(Xi, 2) >= 3
    mi = fit_circle(Xi);
    ri = res_circle(Xi, mi);
else
    ri = 10;
end

if size(Xj, 2) >= 3
    mj = fit_circle(Xj);
    rj = res_circle(Xj, mj);
else
    rj = 10;
end

if size(Xij, 2) >= 3
    mij = fit_circle(Xij);
    rij = res_circle(Xij, mij);
else
    rij = 10;
end

% compute squared residual
rSqri = ri.^2;
rSqrj = rj.^2;
rSqrij = rij.^2;
if(nargin < 6)
% compute std
    sigmai = std(rSqri);
    sigmaj= std(rSqrj);
    sigmaij = std(rSqrij);
    sigma = min([sigmai, sigmaj, sigmaij]);
end
%% compute gric score
% gric score before the merge (the sum of gric on individual models)
<<<<<<< HEAD:DendrogramUtils/isMergeableGricLine.m
[gi, dfi, mci]  = getGricScore(rSqri, sigma, lambda1, lambda2);
[gj, dfj, mcj] = getGricScore(rSqrj, sigma, lambda1, lambda2);
=======
[gi, dfi, mci]  = getGricScore(rSqri, sigma, lambda1);
[gj, dfj, mcj] = getGricScore(rSqrj, sigma, lambda1);
>>>>>>> origin/comments:DynamicTreeAlgorithm/isMergeableGricCircle.m
gBefore = gi + gj;
dfBefore = dfi + dfj;
mcBefore = mci + mcj;
% gric score after the merge
<<<<<<< HEAD:DendrogramUtils/isMergeableGricLine.m
[gAfter, dfAfter, mcAfter]  = getGricScore(rSqrij, sigma, lambda1, lambda2);
=======
[gAfter, dfAfter, mcAfter]  = getGricScore(rSqrij, sigma, lambda1);
>>>>>>> origin/comments:DynamicTreeAlgorithm/isMergeableGricCircle.m
%% compare gric score
ok = gAfter < gBefore;
%% package result
msScore.model = 'circle';
msScore.gric.before = gBefore;
msScore.fidelity.before = dfBefore;
msScore.complexity.before = mcBefore;
msScore.gric.after = gAfter;
msScore.fidelity.after = dfAfter;
msScore.complexity.after = mcAfter;

msOutput.Xi = Xi;
msOutput.Xj = Xj;
msOutput.Xij = Xij;
%msOutput.mi = mi;
%msOutput.mj = mj;
%msOutput.mij = mij;
msOutput.ri = ri;
msOutput.rj = rj;
msOutput.rij = rij;

if all(isnan(mean(ri, 'omitnan')))
    msOutput.Mri = 100;
else
    msOutput.Mri = mean(ri, 'omitnan');
end

if all(isnan(mean(rj, 'omitnan')))
    msOutput.Mrj = 100;
else
    msOutput.Mrj = mean(rj, 'omitnan');
end

if all(isnan(mean(rij, 'omitnan')))
    msOutput.Mrij = 100;
else
    msOutput.Mrij = mean(rij, 'omitnan');
end

end