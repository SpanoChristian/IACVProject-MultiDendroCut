function [OK, gScoreBefore, gScoreAfter, V, AltB] = exploreBFS(C, X, tree, lambda1, lambda2, inlierThreshold)
    
    sigma = inlierThreshold;
    OK = false(1, 0);
    gScoreBefore = [];
    gScoreAfter = [];
    gFidelityBefore = [];
    gFidelityAfter = [];
    gComplexityBefore = [];
    gComplexityAfter = [];
    perc = 0;
    
%     % Initialize the waitbar
%     wait_step = 10; % Update waitbar every wait_step iterations
%     h = waitbar(0, 'Exploring the nodes to be cut...');
    
    % Idea: Depth-First-Search + apply GRIC at each visited node
     
    V = [];                    % visited nodes
    S = C;                     % stack - init: root node
    
%     figure
    
%     it = 1;
    
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
          
        [newOk, gricScore, ~] = isMergeableGricLine(XLR, XL, XR, ...
            lambda1, lambda2, sigma);
        
        OK(end+1) = newOk;
        gScoreBefore(end+1) = gricScore.gric.before;
        gScoreAfter(end+1) = gricScore.gric.after;
        gFidelityBefore(end+1) = gricScore.fidelity.before;
        gFidelityAfter(end+1) = gricScore.fidelity.after;
        gComplexityBefore(end+1) = gricScore.complexity.before;
        gComplexityAfter(end+1) = gricScore.complexity.after;
%         
%         disp([["Fidelity Before : " gFidelityBefore(end)]; ... 
%             ["Fidelity After : " gFidelityAfter(end)]; ...
%             ["Complexity Before : " gComplexityBefore(end)]; ...
%             ["Complexity After : " gComplexityAfter(end)]])
%         
%         disp(gScoreAfter(end) + " <= " + gScoreBefore(end) + " ?")
        
%         subplot(1, 2, 1)
%         plot(XLR(1, :), XLR(2, :), "o", "MarkerFaceColor", "b")
%         title("Joined Cluster")
%         xlim([-1 1])
%         ylim([-1 1])
%         axis square
%         
%         subplot(1, 2, 2)
%         plot(XL(1, :), XL(2, :), "o", "MarkerFaceColor", "g")
%         title("Cluster split")
%         xlim([-1 1])
%         ylim([-1 1])
%         axis square
%         if size(XL, 2) >= 2
%             cXL = fitline(XL);
%         end
%         hold on
%         plot(XR(1, :), XR(2, :), "o", "MarkerFaceColor", "r")
%         axis square
%         if size(XR, 2) >= 2
%             cXR = fitline(XR);
%         end
%         
%         drawLines(cXL, "--", "b")
%         drawnow;
%         drawLines(cXR, "--", "r")
%         drawnow;
%         legend("L Clust", "R Clust", "FitLine L", "Fitline R")   
%         
        V = [V currNode];
        S(1) = [];
        
        if isleaf(childL, X) && isleaf(childR, X)
            % Do something... what?
        elseif isleaf(childL, X) && ~isleaf(childR, X) && gScoreAfter(end) > gScoreBefore(end)
            S = [S childR];
        elseif ~isleaf(childL, X) && isleaf(childR, X) && gScoreAfter(end) > gScoreBefore(end)
            S = [S childL];
        elseif gScoreAfter(end) > gScoreBefore(end)
            S = [S [childL childR]];
        end
% 
%         hold off

%         perc = round(length(V)/size(tree, 1), 2);
%         % Update the waitbar every wait_step iterations
%         if mod(it, wait_step) == 0
%             waitbar(perc, h, sprintf('Progress: %d%%', perc*100));
%         end
%         
%         it = it + 1;
        
    end
    
%     figure
%     plot(gScoreBefore, "r-", "LineWidth", 1)
%     hold on
%     plot(gScoreAfter, "b--", "LineWidth", 1)
   
    [~, idxAltB] = find(gScoreAfter < gScoreBefore);
    AltB = V(idxAltB);
%     
%     plot(idxAltB, gScoreAfter(idxAltB), "o", "MarkerSize", 7, "MarkerFaceColor", "g");
%     legend("Gric before", "Gric after", "gAfter < gBefore")
 
end

