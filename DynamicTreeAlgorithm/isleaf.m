function leaf = isleaf(node, X)
%ISLEAF
% if node value is bigger than the size of X, it means that it comes from
% merging, so it is a cluster
% Outputs
%   leaf: 1 (true) if is leaf, 0 (false) otherwise

    leaf = 0;
    if node <= size(X, 2)
        leaf = 1;
    end
end

