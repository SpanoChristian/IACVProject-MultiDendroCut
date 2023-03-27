addpath(genpath('.'));
% This code just simply run the T-Linkage algorithm on the example data set
% "star5".
% Loading data: X contains data points, whereas G is the ground truth
% segmentation
load './Dataset/star5.mat'; N = size(X,2);
% In order to work with a specific model, T-Linkage needs to be given:
% - distFun: distance between points and models
% - hpFun: returns an estimate model given cardmss points
% - fit_model: least square fitting function
% 
% In this example we want to estimate lines so distFun is the euclidean
% distance between a point from a line in the plane and cardmss=2.
% Other  possible models are 'line', 'circle',
% fundamental matrices ('fundamental') and 'subspace4' (look in 'model_spec' folder).
%

[distFun, hpFun, fit_model, cardmss] = set_model('line');
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
%% Outlier rejection step

%T-Linkage fit a model to all the data points. Outlier can be found in
%different ways (T-Linkage is agonostic about the outlier rejection strategy),
%for example discarding too small cluster, or exploiting the randomness of
%a model.
C  = outlier_rejection_card( C, cardmss );
% Outliers are labelled by '0'
%% Showing results
figure
subplot(1,2,1); gscatter(X(1,:),X(2,:),G); axis equal; title('GroundTruth'); legend off
subplot(1,2,2); gscatter(X(1,:),X(2,:),C); axis equal; title('T linkage'); legend off

%%
W = linkage_to_tree(T);
root = W(end, 3);
[OK, gBefore, gAfter, V, AgtB] = explore(root, X, W)

%% Reference
% When using the code in your research work, please cite the following paper:
% Luca Magri, Andrea Fusiello, T-Linkage: A Continuous Relaxation of
% J-Linkage for Multi-Model Fitting, CVPR, 2014.
%
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it