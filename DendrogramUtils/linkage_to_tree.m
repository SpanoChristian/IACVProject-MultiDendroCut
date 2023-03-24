% Function to convert a linkage matrix to a tree representation

% Inputs:
%   - linkage_matrix: linkage matrix obtained from J-Linkage (or T-Linkage)

% Output:
%   - tree: tree representation of the hierarchical clustering.
%           It is a (n-1)x3 matrix where the first two cols are exactly the
%           same, whilst the 3rd column is the index of the cluster

function tree = linkage_to_tree(linkage_matrix)
    % Get the number of data points in the dataset
    n = size(linkage_matrix, 1) + 1;
    
    % Initialize the tree matrix to a zeros matrix with n-1 rows and 3 cols
    tree = zeros(n-1, 3);
    
    % Initialize the index variable k to 1
    % This will be used to add new rows
    k = 1;

    % Iterate over the rows of the linkage matrix
    for i = 1:n-1
        % Copy the indices of the two clusters being merged to the i-th
        % row of the tree matrix
        tree(k, 1) = linkage_matrix(i, 1);
        tree(k, 2) = linkage_matrix(i, 2);
        
        % Set the third column of the i-th row of the tree matrix to the
        % index of the new merged cluster
        tree(k, 3) = n + i;
        
        % Increment the index variable k
        k = k + 1;
    end
end

