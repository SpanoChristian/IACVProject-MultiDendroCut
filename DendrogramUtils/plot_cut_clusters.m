function lbls = plot_cut_clusters(X, tree, AgtB, lblG, lblC)
    sizeAgtB = length(AgtB);
    colors = ["b" "g" "y" "c" "m" "#EDB120" "#4DBEEE" ...
        "#0072BD" "#D95319" "#7E2F8E" "#77AC30" "#A2142F" "k"];
    legend_labels = {};
    lbls = zeros(length(X), 1);
    
    figure
    subplot(1, 3, 1)
    gscatter(X(1,:), X(2,:), lblG); axis square; title('GroundTruth')
    
    subplot(1, 3, 2)
    gscatter(X(1,:), X(2,:), lblC); axis square; title('T linkage');
    
    xlim([-1 1])
    ylim([-1 1])
    
    for i = 1:sizeAgtB
        idxAB = get_cluster_idxPoints(AgtB(i), X, tree);
        P = get_cluster_points(X, idxAB);
        subplot(1, 3, 3)
        if length(P) > 30
            plot(P(1, :), P(2, :), "o", "MarkerFaceColor", colors(i))
            legend_labels{end+1} = ["Cluster " + i + " (" + size(P, 2) + "pts)"];
            legend(legend_labels);
            hold on
            lbls(idxAB) = i+1;
        end

    end
    
    legend(legend_labels);
    axis square;
    xlim([-1 1])
    ylim([-1 1])
    title("T linkage w/ Dynamic Cut")
    hold off
    
end

