function [leaves] = getLeavesFromNode(node, tree)
%GETLEAVESFROMNODE Summary of this function goes here
%   Detailed explanation goes here
    
    leaves =[];
    [childL, childR] = get_children(node, tree);
    
    if isempty(childL) && isempty(childR)
        leaves = node;
    else
        if ~isempty(childL)
            leaves = [getLeavesFromNode(childL, tree)];
        end
        
        if ~isempty(childR)
            leaves = [leaves getLeavesFromNode(childR, tree)];
        end
    end

end

