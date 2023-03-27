function [OK, gScoreBefore, gScoreAfter, V, AgtB] = explore(C, X, tree)
    
    epsi = 2e-2; % inlier threhsold
    lambda1 = 1;
    lambda2 = 2;
    sigma = epsi;
    OK = [];
    gScoreBefore = [];
    gScoreAfter = [];
    
    % Idea: Depth-First-Search + apply GRIC at each visited node
     
    V = [];                    % visited nodes
    S = C;                     % stack - init: root node
    
    figure
    
    while ~isempty(S)
        
        currNode = S(1);
        [childL, childR] = get_children(currNode, tree);

        idxL = get_cluster_idxPoints(childL, X, tree);
        idxR = get_cluster_idxPoints(childR, X, tree);
        XL = X(:, idxL);    % points in cluster corresponding to left node
        XR = X(:, idxR);    % points in cluster corresponding to right node
        XLR = X(:, union(idxL, idxR));  % points in current cluster
        
        %disp(XL)
        %disp(XR)
        disp(["XLR" size(XLR)])
        disp(["Current node: " currNode])
        
        [newOk, gricScore, out] = isMergeableGricLine(XLR, XL, XR, ...
            lambda1, lambda2, sigma);
        
        OK(end+1) = newOk;
        gScoreBefore(end+1) = gricScore.gric.before;
        gScoreAfter(end+1) = gricScore.gric.after;
        
        subplot(1, 2, 1)
        plot(XLR(1, :), XLR(2, :), "o", "MarkerFaceColor", "b")
        xlim([-1 1])
        ylim([-1 1])
        axis square
        
        subplot(1, 2, 2)
        plot(XL(1, :), XL(2, :), "o", "MarkerFaceColor", "g")
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
        
        drawLines(cXL)
        drawnow;
        drawLines(cXR)
        drawnow;
        
        V = [V currNode];
        S(1) = [];
        
        if isleaf(childL, X) && isleaf(childR, X)
            disp(["Is a child : " childL])
            disp(["Is a child : " childR])
        elseif isleaf(childL, X) && ~isleaf(childR, X)
            S = [childR S];
        elseif ~isleaf(childL, X) && isleaf(childR, X)
            S = [childL S];
        else
            S = [[childL childR] S];
        end
        
        disp(["Visited Node : " currNode])
        disp(["Stack : " S])
        
        hold off
        %pause(1)
        

    
    end
    
    figure
    plot(gScoreBefore, "r-", "LineWidth", 1)
    hold on
    plot(gScoreAfter, "b--", "LineWidth", 1)
    
    [~, idxAgtB] = find(gScoreAfter > gScoreBefore);
    AgtB = V(idxAgtB);
    
    disp(["Size idxAgtB : " size(idxAgtB)])
    disp(["Size AgtB : " size(AgtB)])
    
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

