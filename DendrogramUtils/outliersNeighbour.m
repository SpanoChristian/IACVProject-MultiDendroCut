function outliers = outliersNeighbour(X)

% Define the number of neighbors to use in LOF calculation
k = 40;

% Calculate pairwise distances between data points
D = pdist2(X, X);

% Calculate the k-nearest neighbors for each data point
[~, idx] = sort(D, 2);
knn_idx = idx(:, 2:k+1);

% Compute the reachability distances for each data point
reach_dist = zeros(size(X, 1), k);
for i = 1:size(X, 1)
    for j = 1:k
        neighbor = knn_idx(i, j);
        dist = D(i, neighbor);
        reach_dist(i, j) = max(dist, max(reach_dist(neighbor, 1:min(k, size(reach_dist, 2)))));
    end
end

% Compute the local reachability density for each data point
lrd = k ./ sum(reach_dist, 2);

% Compute the LOF for each data point
lof = zeros(size(X, 1), 1);
for i = 1:size(X, 1)
    lrd_ratio = lrd(knn_idx(i, :)) ./ lrd(i);
    lof(i) = mean(lrd_ratio);
end

% Set a threshold for outliers
thresh = 1.45;

% Identify outliers
outliers = find(lof >= thresh);
    
end

