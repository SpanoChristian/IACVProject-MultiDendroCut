function [ariScore, nmiScore] = compare_clustering(y_true, y_pred1, y_pred2)
% Computes the Adjusted Rand Index and Normalized Mutual Information for two sets of cluster labels
% Inputs:
%   - y_true: true labels of the data points
%   - y_pred1: predicted cluster labels by algorithm 1
%   - y_pred2: predicted cluster labels by algorithm 2
% Outputs:
%   - ari: Adjusted Rand Index between the two sets of cluster labels
%   - nmi: Normalized Mutual Information between the two sets of cluster labels

% Compute the ARI and NMI for algorithm 1
ari1 = rand_index(y_true, y_pred1, 'adjusted');
nmi1 = nmi(y_true, y_pred1);

% Compute the ARI and NMI for algorithm 2
ari2 = rand_index(y_true, y_pred2, 'adjusted');
nmi2 = nmi(y_true, y_pred2);

ariScore = [ari1 ari2];
nmiScore = [nmi1 nmi2];

% Print the results
fprintf('ARI of T-Linkage: %f\n', ari1);
fprintf('ARI of Dynamic T-Linkage: %f\n', ari2);
fprintf('NMI of T-Linkage: %f\n', nmi1);
fprintf('NMI of Dynamic T-Linkage: %f\n', nmi2);

% Compare the two algorithms
if ari1 > ari2
    fprintf('T-Linkage has a higher ARI than Dynamic T-Linkage\n');
elseif ari2 > ari1
    fprintf('Dynamic T-Linkage has a higher ARI than T-Linkage\n');
else
    fprintf('T-Linkage and Dynamic T-Linkage have the same ARI\n');
end

if nmi1 > nmi2
    fprintf('T-Linkage has a higher NMI than Dynamic T-Linkage\n');
elseif nmi2 > nmi1
    fprintf('Dynamic T-Linkage has a higher NMI than T-Linkage\n');
else
    fprintf('T-Linkage and Dynamic T-Linkage have the same NMI\n');
end

end
