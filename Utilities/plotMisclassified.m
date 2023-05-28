function plotMisclassified(points, GTL, TLLabels, DTLLabels)
%PLOT MISCLASSIFIED show all points that have a different label
% very simple way: just check the numbers assigned to points,
% doesn't check for permutation
   
    assert((size(points, 1) == 2) && (size(TLLabels,2) == 1) && (size(DTLLabels, 2) == 1), ...
        "Assertion failed while plotting misclassified points. Check sizes of input parameters")

    plotBoundaries = 0.1;
    xBoundaries = [min(points(1,:)) - plotBoundaries max(points(1,:)) + plotBoundaries];
    yBoundaries = [min(points(2,:)) - plotBoundaries max(points(2,:)) + plotBoundaries];
    
    differentLabelledTL = find(GTL ~= TLLabels);
    differentLabelledDTL = find(GTL ~= DTLLabels);
    
    
    figure('name','Misclassified points')
        s = subplot(1,3,1); gscatter(points(1,:),points(2,:), GTL); axis(s, 'equal'); xlim(s, xBoundaries); ylim(s, yBoundaries); title('GroundTruth'); legend off
        s = subplot(1,3,2); gscatter(points(1,differentLabelledTL),points(2,differentLabelledTL), TLLabels(differentLabelledTL)); axis(s, 'equal'); xlim(s, xBoundaries); ylim(s, yBoundaries); title('T linkage'); legend off
        s = subplot(1,3,3); gscatter(points(1,differentLabelledDTL),points(2,differentLabelledDTL), DTLLabels(differentLabelledDTL)); axis(s, 'equal'); xlim(s, xBoundaries); ylim(s, yBoundaries); title('Dyn T linkage'); legend off

end