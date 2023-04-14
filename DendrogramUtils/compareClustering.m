function [misclassErr, ariScore, nmiScore, arinmiScore] = compareClustering(y_true, y_pred1, y_pred2)
% Computes the Adjusted Rand Index and Normalized Mutual Information for two sets of cluster labels
% Inputs:
%   - y_true: true labels of the data points
%   - y_pred1: predicted cluster labels by algorithm 1
%   - y_pred2: predicted cluster labels by algorithm 2
% Outputs:
%   - ari: Adjusted Rand Index between the two sets of cluster labels
%   - nmi: Normalized Mutual Information between the two sets of cluster labels

    % Compute the ARI and NMI for algorithm 1 (Tlinkage)
    misclassified_points1 = find(y_true ~= y_pred1);
    me1 = length(misclassified_points1) / length(y_true);
    ari1 = rand_index(y_true, y_pred1, 'adjusted');
    nmi1 = nmi(y_true, y_pred1);
    
    % Compute the ARI and NMI for algorithm 2 (Dyn Tlinkage)
    misclassified_points2 = find(y_true ~= y_pred2);
    me2 = length(misclassified_points2) / length(y_true);
    ari2 = rand_index(y_true, y_pred2, 'adjusted');
    nmi2 = nmi(y_true, y_pred2);
    
    misclassErr = [me1 me2];
    ariScore = [ari1 ari2];
    nmiScore = [nmi1 nmi2];
    arinmiScore = [ari1.*nmi1 ari2.*nmi2];
end
