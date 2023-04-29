function [metrics] = compareClustering(y_true, y_pred1)
% Computes the Adjusted Rand Index and Normalized Mutual Information for two sets of cluster labels

% Inputs:
%   - y_true: true labels of the data points
%   - y_pred1: predicted cluster labels by algorithm 1
% Outputs:
%   - ari: Adjusted Rand Index between the two sets of cluster labels
%   - nmi: Normalized Mutual Information between the two sets of cluster labels

    % Compute the ARI and NMI for algorithm 1 (Tlinkage)
    metrics.misclassErr = length(find(y_true ~= y_pred1)) / length(y_true);
    metrics.ariScore = rand_index(y_true, y_pred1, 'adjusted');
    metrics.nmiScore = nmi(y_true, y_pred1); %rand_index(y_true, y_pred1, 'adjusted');
    metrics.arinmiScore = metrics.ariScore * metrics.nmiScore;

end
