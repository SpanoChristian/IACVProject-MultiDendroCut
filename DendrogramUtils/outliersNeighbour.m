function outliers = outliersNeighbour(X)

% Define the number of neighbors to use in LOF calculation
k = 50;

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

% Display the outliers
disp('The following data points are outliers:');
disp(outliers);

%     
%     outK = [];
%     maxK = 20;
%     candidateOutliers = cell(1, maxK);
%     ratio = cell(1, maxK);
%     
%     for k = 2:maxK
%         [neighbor, ~] = knnsearch(X', X', 'K', k+1);
%         
%         for i = 1:length(lbls)
%             if lbls(i) ~= 0
%                 idxWindow = neighbor(i, 2:k+1);
%                 window = lbls(idxWindow);
% 
%                 r = sum(window ~= 0)/(sum(window == 0) + 0.001);
% 
%                 if r < 0.25
%                     candidateOutliers{k-1} = [candidateOutliers{k-1} i]; 
%                     ratio{k-1} = [ratio{k-1} r];
%                 end
%             end
%         end
%         
%         disp("Candidate : " + candidateOutliers{k-1})
%         disp("Length Candidate : " + length(candidateOutliers{k-1}))
%         
%         outK(k-1) = length(candidateOutliers{k-1});
% 
%     end
%     
%     [~, bestK] = max(outK);
%     candidateOutliers = candidateOutliers{bestK};
%     ratio = ratio{bestK};
%     
%     bestK = bestK + 1;
    
end

