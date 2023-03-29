function [N, meanN, stdN, CI] = clusterNumPoints(labels)
    lbls = unique(labels(labels ~= 0));
    N = zeros(length(lbls), 1);
    
    for l = 1:length(lbls)
        N(l, 1) = sum(labels == l);
    end
    
    stdN = std(N);
    meanN = mean(N);
    stdE = stdN/sqrt(length(N));                % Standard Error
    ts = tinv([0.005  0.995], length(N)-1);     % T-Score
    CI = meanN + ts*stdE;                       % Confidence Interval
end

