function [C, T] = tlinkage(X)

[distFun, hpFun, fit_model, cardmss] = set_model('line');
N = size(X, 2);

%% Conceptual representation of points

%T-linkage starts, as Ransac with random sampling:
% Unform sampling can be adopted
S = mssUniform(X, 5*N, cardmss)
% in order to reduce the number of hypotheses also a localized sampling can
% be used:
%
%       D = pdist(X','euclidean');  D = squareform(D);
%       S = mssNorm( X, D, 2*N, cardmss);
%

H = hpFun( X, S );
% generating a pool of putative hypotheses H.
% The residuals R between points and model
R = res( X, H, distFun );
% are used for representing points in a conceptual space.
% In particular a preference matrix P is built depicting by rows points
% preferences.
% 

epsilon= 1.3e-1; %An inlier threshold value  epsilon has to be specified.
P  = prefMat( R, epsilon, 1 );

%% Clustering

%T-Linkage clustering follow a bottom up scheme in the preference space

[C, T] = tlnk(P); % C = tlnk_fast(P);

% C is a vector of labels, points belonging to the same models share the
% same label.
end

