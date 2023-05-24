function G = generateGTLbls(numClusters, ptsPerCluster, numOutliers)
    G = [];
    if length(ptsPerCluster) == 1
        ptsPerCluster = ptsPerCluster * ones(numClusters, 1);
    end

    for i = 1:length(ptsPerCluster)
        display("PtsPerCluster i " + i + " are " + ptsPerCluster(i))
        G = [G; i*ones(ptsPerCluster(i), 1)];
    end
    
    G(end+1:end+numOutliers) = 0;
end

