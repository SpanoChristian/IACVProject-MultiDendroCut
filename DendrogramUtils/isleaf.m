function leaf = isleaf(node, X)
    leaf = 0;
    if node <= size(X, 2)
        leaf = 1;
    end
end

