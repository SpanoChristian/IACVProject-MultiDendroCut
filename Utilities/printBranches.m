function printBranches(tree, X, root)
%PRINTBRANCHES show all points belonging to a cluster with that
%specified root (blue) and ones not belonging (red)

% Inputs:
%   tree: matrix describing tree
%   X: leaf points of tree
%   root: desired root for tree visualization

    % Detect all figures - close the figures that are not the GUI
    fh=findall(0,'type','figure');
    nfh=length(fh); % Total number of open figures, including GUI and figures with visibility 'off'
    % Scan through open figures - GUI figure number is [] (i.e. size is zero)
    for i = 1:nfh 
        if isempty(fh(i).Number) % checks if length(fh(i).Number) == 0
            close(fh(i));
        end
    end
    
    [childL, childR] = get_children(root, tree);
    parent = get_node_parent(root, tree);

    if isempty(childR) || isempty(childL)
        root = get_node_parent(root, tree);
        [childL, childR] = get_children(root, tree);
        parent = get_node_parent(root, tree);
    end
    
    %display("ChildL: " + childL +"; ChildR: " + childR);
    clusterL = get_cluster_idxPoints(childL, X, tree);
    clusterR = get_cluster_idxPoints(childR, X, tree);
    cluster = [clusterL, clusterR];
    leftOut = 1:length(X);
    leftOut = leftOut(~ismember(leftOut, cluster));

    leftBranch = "Left Branch  (" + childL + ")";
    rightBranch = "Right Branch  (" + childR + ")";
    parentBranch = "Parent (" + parent + ")";
    
    treeFigure = uifigure; 
    g = uigridlayout(treeFigure, [3 3]);   


    ax = uiaxes(g);
    ax.Layout.Row = [1 2];
    ax.Layout.Column = [1 2];

    if length(leftOut) > 0
        coeff = fitline(X(:,leftOut))
        m = coeff(1)/coeff(2) * (-1);
        q = coeff(3)/coeff(2) * (-1);
        plot(ax, X(1, leftOut), m * X(1, leftOut) + q, "-", "MarkerFaceColor", "r", "DisplayName", "Fitted NB");
        hold(ax, 'on');
        plot(ax, X(1, leftOut), X(2, leftOut), "o", "MarkerFaceColor", "r", "DisplayName", "Not Belonging");
        hold(ax, 'on');
    end

    if length(clusterL) > 0
        coeff = fitline(X(:,clusterL))
        m = coeff(1)/coeff(2) * (-1);
        q = coeff(3)/coeff(2) * (-1);
        plot(ax, X(1, clusterL), m * X(1, clusterL) + q, "-", "MarkerFaceColor", "g", "DisplayName", "Fitted L: " + childL);
        hold(ax, 'on');
        plot(ax, X(1, clusterL), X(2, clusterL), "o", "MarkerFaceColor", "g", "DisplayName", "leftBranch");
        hold(ax, 'on');
    end
    if length(clusterR) > 0
        coeff = fitline(X(:,clusterR))
        m = coeff(1)/coeff(2) * (-1);
        q = coeff(3)/coeff(2) * (-1);
        plot(ax, X(1, clusterR), m * X(1, clusterR) + q, "-", "MarkerFaceColor", "b", "DisplayName", "Fitted R: " + childR);
        hold(ax, 'on');
        plot(ax, X(1, clusterR), X(2, clusterR), "o", "MarkerFaceColor", "b", "DisplayName", "rightBranch");
        hold(ax, 'on');
    end


    coeff = fitline(X)
    m = coeff(1)/coeff(2) * (-1);
    q = coeff(3)/coeff(2) * (-1);
    plot(ax, X(1, :), m * X(1, :) + q, "-", "MarkerFaceColor", "k", "DisplayName", "Fitted P: " + root);
    hold(ax, 'on');
    
    legend(ax, 'Location','bestoutside');
    title(ax, "Points belonging to cluster " + root);

    xlim(ax, [-1 1]);
    ylim(ax, [-1 1]);
    axis(ax, 'square');
    



    leftButton = uibutton(g, ...
        "Text",leftBranch, ...
        "ButtonPushedFcn", @(src,event) printBranches(tree, X, childL));
    leftButton.Parent
    leftButton.Layout.Row = 1;
    leftButton.Layout.Column = 3;

    rightButton = uibutton(g, ...
        "Text", rightBranch, ...
        "ButtonPushedFcn", @(src,event) printBranches(tree, X, childR));
    rightButton.Layout.Row = 2;
    rightButton.Layout.Column = 3;

    

    parentButton = uibutton(g, ...
        "Text", parentBranch, ...
        "ButtonPushedFcn", @(src,event) printBranches(tree, X, parent));
    parentButton.Layout.Row = 3;
    parentButton.Layout.Column = 3;

    
    
    if false 
    %% just for easy setup
    % run this section before calling function
        
        %run once
        close all % close all figures
        addpath(genpath('.'));
        labelled_data = false;

        % This code just simply run the T-Linkage algorithm on the example data set
        % "star5".
        % Loading data: X contains data points, whereas G is the ground truth
        % segmentation
        
        [X, G, nTotPoints, nRealPoints, nOutliers, nClusters, ~] = getDatasetAndInfo(labelled_data, 4);
        [distFun, hpFun, fit_model, cardmss, isMergeableGricModel] = set_model('line');
        
        epsilon = 0.085; % An inlier threshold value  epsilon has to be specified.
        
        
        [lblsTLinkage, T] = t_linkage(X, distFun, epsilon, cardmss, hpFun);

        tree = linkage_to_tree(T);

        %%

    end

  
end
