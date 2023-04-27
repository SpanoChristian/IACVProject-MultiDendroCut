function [labels, finalMatrix] = t_linkage(X, distanceFunction, epsilon, cardmss, hpFun)
%T_LINKAGE Summary of this function goes here
%   Detailed explanation goes here
% Input
%   X: Points
%   distanceFunction: df between points
%   epsilon: max distance (can be not euclidean) between points/clusters possible
%   cardmss: minimum number of points to define the model
%   hpFun: function to generate hp according to the required model
% Output
%   labels: vector of labels assigned by T-Linkage to all points
%   finalMatrix: T-Linkage matrix


    N = size(X, 2);
    % In order to work with a specific model, T-Linkage needs to be given:
    % - distFun: distance between points and models
    % - hpFun: returns an estimate model given cardmss points
    % - fit_model: least square fitting function
    
    
    % In this example we want to estimate lines so distFun is the euclidean
    % distance between a point from a line in the plane and cardmss=2.
    % Other  possible models are 'line', 'circle',
    % fundamental matrices ('fundamental') and 'subspace4' (look in 'model_spec' folder).
    
   
    
    %% Conceptual representation of points
    
    %T-linkage starts, as Ransac with random sampling:
    % Unform sampling can be adopted
    S = mssUniform(X, 5*N, cardmss);
    % in order to reduce the number of hypotheses also a localized sampling can
    % be used:
    %
    %       D = pdist(X','euclidean');  D = squareform(D);
    %       S = mssNorm( X, D, 2*N, cardmss);
    %
    
    H = hpFun(X, S); 
    % generating a pool of putative hypotheses H.
    % The residuals R between points and model
    R = res(X, H, distanceFunction);
    % are used for representing points in a conceptual space.
    % In particular a preference matrix P is built depicting by rows points
    % preferences.
    % 
    
    P = prefMat(R, epsilon, 1);
    
    %% Clustering
    
    %T-Linkage clustering follow a bottom up scheme in the preference space
    
    [labels, finalMatrix] = tlnk(P);
    
    % C is a vector of labels, points belonging to the same models share the
    % same label.
end

