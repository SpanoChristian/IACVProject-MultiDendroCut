function [OK, gScoreBefore, gScoreAfter, V, AgtB] = exploreDFS(C, X, tree)
    
    epsi = 2e-2; % inlier threhsold
    lambda1 = 1;
    lambda2 = 2;
    sigma = epsi;
    OK = false(1, 0);
    gScoreBefore = [];
    gScoreAfter = [];
    perc = 0;
    
    % Initialize the waitbar
    wait_step = 10; % Update waitbar every wait_step iterations
    h = waitbar(0, 'Exploring the nodes to be cut...');
    
    % Idea: Depth-First-Search + apply GRIC at each visited node
     
    V = [];                    % visited nodes
    S = C;                     % stack - init: root node
    
    figure
    
    it = 1;
    
    while ~isempty(S)
        
        disp("------- New Iteration -------")
        currNode = S(1);
        [childL, childR] = get_children(currNode, tree);
       
        idxL = get_cluster_idxPoints(childL, X, tree);
        idxR = get_cluster_idxPoints(childR, X, tree);
        XL = X(:, idxL);    % points in cluster corresponding to left node
        XR = X(:, idxR);    % points in cluster corresponding to right node
        XLR = X(:, union(idxL, idxR));  % points in current cluster
        
        disp([[" XL size : " size(XL)]; [" XR size : " size(XR)]; ["XLR size : " size(XLR)]])
        
        [newOk, gricScore, out] = isMergeableGricLine(XLR, XL, XR, ...
            lambda1, lambda2, sigma);
        
        OK(end+1) = newOk;
        gScoreBefore(end+1) = gricScore.gric.before;
        gScoreAfter(end+1) = gricScore.gric.after;
        
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
        
        V = [V currNode];
        S(1) = [];
        
        if isleaf(childL, X) && isleaf(childR, X)
            % Do something... what?
        elseif isleaf(childL, X) && ~isleaf(childR, X)
            S = [S childR];
        elseif ~isleaf(childL, X) && isleaf(childR, X)
            S = [S childL];
        else
            S = [S [childL childR]];
        end
        
        disp([["Visited Node : " currNode] [" -- Stack : " S]])

        hold off
        
%         if any(isnan(out.ri)) || any(isnan(out.rj)) || any(isnan(out.rij))
%             pause(5)
%         end
        perc = round(length(V)/size(tree, 1), 2);
        % Update the waitbar every wait_step iterations
        if mod(it, wait_step) == 0
            waitbar(perc, h, sprintf('Progress: %d%%', perc*100));
        end
        
        it = it + 1;
        
    end
    
    figure
    plot(gScoreBefore, "r-", "LineWidth", 1)
    hold on
    plot(gScoreAfter, "b--", "LineWidth", 1)
    
    [~, idxAgtB] = find(gScoreAfter < gScoreBefore);
    AgtB = V(idxAgtB);
    
    plot(idxAgtB, gScoreAfter(idxAgtB), "o", "MarkerSize", 7, "MarkerFaceColor", "g");
    legend("Gric before", "Gric after", "After > Before")
  
    %% NO SENSE, JUST TRIALS
%     for k = C:-1:(size(X,2)+1)
%         disp(k)
%         [childL, childR] = get_children(C, tree);
%         
%         
%         idxL = get_cluster_idxPoints(childL, X, tree);
%         idxR = get_cluster_idxPoints(childR, X, tree);
%         disp(["size idxL", size(idxL)])
%         disp(["size idxR", size(idxR)])
%         XL = X(:, idxL);
%         XR = X(:, idxR);
%         XLR = X(:, union(idxL, idxR));
%         %hold off;
        
% 
%         %hold on
% 
%         %scatter(XL(1, :), XL(2, :), "MarkerFaceColor", "g")
%         %legend("Left-Cluster", "Right Cluster")
%         %cXL = fitline(XL);
%         %drawLines(cXL);
%         %hold off
%         
%         [newOk, msScore] = isMergeableGricLine(XLR, XL, XR, lambda1, lambda2, sigma);
%         OK = [OK newOk];
%         %subplot(1, 3, 3);
%         plot(X, "--")
%         hold on
%     end
%     
    
end

