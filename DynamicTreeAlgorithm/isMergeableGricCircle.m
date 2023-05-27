function [ok, msScore] = isMergeableGricCircle(XLR, XL, XR, lambda1, lambda2, totalNumPoints)
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

    fakeSigma = 10;
    
    % consider points in cluster Ci, in cluster Cj and in the union Ci U Cj
    Xi = XL;
    Xj = XR;
    Xij = XLR;
    
    
    %% compute gric score
    % gric score before the merge (the sum of gric on individual models)
    gi = getGricScore(Xi, fakeSigma, lambda1, lambda2, totalNumPoints);
    gj = getGricScore(Xj, fakeSigma, lambda1, lambda2, totalNumPoints);
    gBefore = gi + gj;
    % gric score after the merge
    gAfter  = getGricScore(Xij, fakeSigma, lambda1, lambda2, totalNumPoints);
    %% compare gric score
    ok = gAfter < gBefore;
    %% package result
    msScore.model = 'circle';
    msScore.gric.before = gBefore;
    msScore.gric.after = gAfter;

end