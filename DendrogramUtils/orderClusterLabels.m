function [labels, numLbls] = orderClusterLabels(lbls, clustSize, numPts)
% the most frequent label in x-th cluster is set as label x
% doesn't set label zero to the outliers in each cluster
% We trust that outlier rejection card di so

    uniqueLbls = unique(lbls);
    uniqueLbls = uniqueLbls(uniqueLbls ~= 0);
    numLbls = zeros(length(uniqueLbls), 0);
    
    labels = lbls;
    
    r = 1;
    for lbl = uniqueLbls'
        l = find(lbls == lbl);
        
        c = 1;
        for j = 1:clustSize:numPts
            numLbls(r, c) = sum(l >= j & l < j + 50);
            c = c + 1;
        end
        
        [~, newLbl] = max(numLbls(r, :));
        labels(l) = newLbl;
        
        r = r + 1;
    end
    
end

