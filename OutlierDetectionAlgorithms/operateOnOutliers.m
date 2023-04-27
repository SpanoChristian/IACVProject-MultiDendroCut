function [updatedLabels] = operateOnOutliers(labels, minimumCardinality)
%OUTLIERANALYSIS perform operations to detect further outliers
    % uncomment only if we don't change resulting labels
    updatedLabels  = outlier_rejection_card( labels, minimumCardinality); 
end

