% Function to explore tree through DFS approach, expanding a node only if
% the sum of gric costs of expanded children is smaller than the parent

% Inputs:
%   - rootNode: root node
%   - X: dataset points
%   - tree: matrix representation of the tree
%   - lambda: gric cost parameter
%   - inlierThreshold: inlier threshold related to the given dataset
%
% Outputs:
%   - OK: list of actions suggested (merge/do not merge)
%   - gScoreBefore: list of grics of not merged cluster (for each copy of 
%                   sibiling clusters not merged)
%   - gScoreAfter: list of grics of merged cluster on each cluster name 
%                  (for each cluster obtained merging two sibilings)
%   - V: list of visited nodes
%   - AltB: list of nodes that are better merged than splitted (based on
%           the name of the cluster)

function [OK, gScoreBefore, gScoreAfter, V, AltB] = exploreDFS(root, X, ...
    tree, lambda, inlierThreshold, model2fit, verbose)

    sigma = inlierThreshold;
    OK = false(1, 0);
    gScoreBefore = [];
    gScoreAfter = [];
    gFidelityBefore = [];
    gFidelityAfter = [];
    gComplexityBefore = [];
    gComplexityAfter = [];
    perc = 0;
     
    V = [];                    % visited nodes
    S = root;                  % stack - init: root node
    
    if verbose
        figure
    end
    
    while ~isempty(S)
%         disp("------- New Iteration -------")
        currNode = S(1);
        [childL, childR] = get_children(currNode, tree);
       
        idxL = get_cluster_idxPoints(childL, X, tree);
        idxR = get_cluster_idxPoints(childR, X, tree);
        XL = X(:, idxL);    % points in cluster corresponding to left node
        XR = X(:, idxR);    % points in cluster corresponding to right node
        XLR = X(:, union(idxL, idxR));  % points in current cluster
        
%         disp([[" XL size : " size(XL)]; [" XR size : " size(XR)]; ...
%               ["XLR size : " size(XLR)]])
%         disp(["Current Node : " currNode])
          
        [newOk, gricScore, ~] = model2fit(XLR, XL, XR, lambda, sigma);
        
        % before: when clusters are not merged
        % after: when clusters are merged
        % we will split (expand) if after < before

        OK(end+1) = newOk;
        gScoreBefore(end+1) = gricScore.gric.before;
        gScoreAfter(end+1) = gricScore.gric.after;
        gFidelityBefore(end+1) = gricScore.fidelity.before;
        gFidelityAfter(end+1) = gricScore.fidelity.after;
        gComplexityBefore(end+1) = gricScore.complexity.before;
        gComplexityAfter(end+1) = gricScore.complexity.after;
        
        if verbose
            subplot(1, 2, 1)
            plot(XLR(1, :), XLR(2, :), "o", "MarkerFaceColor", "b")
            title("Joined Cluster")
            xlim([-1 1])
            ylim([-1 1])
            axis square

            subplot(1, 2, 2)
            plot(XL(1, :), XL(2, :), "o", "MarkerFaceColor", "g")
            title("Cluster split")
            xlim([-1 1])
            ylim([-1 1])
            axis square
            if size(XL, 2) >= 2
                cXL = fitline(XL);
            end
            hold on
            plot(XR(1, :), XR(2, :), "o", "MarkerFaceColor", "r")
            axis square
            if size(XR, 2) >= 2
                cXR = fitline(XR);
            end

            drawLines(cXL, "--", "b")
            drawnow;
            drawLines(cXR, "--", "r")
            drawnow;
            legend("L Clust", "R Clust", "FitLine L", "Fitline R")
            
            hold off
        end

%         disp([["Fidelity Before : " gFidelityBefore(end)]; ... 
%                 ["Fidelity After : " gFidelityAfter(end)]; ...
%                 ["Complexity Before : " gComplexityBefore(end)]; ...
%                 ["Complexity After : " gComplexityAfter(end)]])
%         disp([gScoreAfter(end) " <= " gScoreBefore(end) " ?"])
        
        V = [V currNode];
        S(1) = [];
        
        if isleaf(childL, X) && isleaf(childR, X)
            % Do something... what?
        elseif isleaf(childL, X) && ~isleaf(childR, X) && gScoreAfter(end) > gScoreBefore(end)
            S = [childR S];
        elseif ~isleaf(childL, X) && isleaf(childR, X) && gScoreAfter(end) > gScoreBefore(end)
            S = [childL S];
        elseif gScoreAfter(end) > gScoreBefore(end)
            S = [[childL childR] S];
        end
        
    end
   
    % find all the clusters that are better if merged
    [~, idxAltB] = find(gScoreAfter < gScoreBefore);
    
    % return name of clusters that are better if merged
    AltB = V(idxAltB);

end
