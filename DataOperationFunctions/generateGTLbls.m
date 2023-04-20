function G = generateGTLbls(numClusters, ptsPerCluster, numOutliers)
    G = [];

    for i = 1:numClusters
        G = [G; i*ones(ptsPerCluster, 1)]; %#ok<*AGROW>
    end
    
    G(end+1:end+numOutliers) = 0;
end

