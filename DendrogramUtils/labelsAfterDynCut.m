function lbls = labelsAfterDynCut(X, tree, AltB)
    sizeAltB = length(AltB);
    lbls = zeros(length(X), 1);
    l = 0;
    
    for i = 1:sizeAltB
        idxAB = get_cluster_idxPoints(AltB(i), X, tree);
        P = get_cluster_points(X, idxAB);
        if length(P) > 30
%             l = l + 1;
%             lbls(idxAB) = l;
            medIdxAB = median(idxAB);
            % Just for the purpose of theoretical results we do this
            % In practice it does not make any sense and we should just
            % rely on ARI and NMI
            if medIdxAB > 0 && medIdxAB <= 50
                lbls(idxAB) = 1;
            elseif medIdxAB > 50 && medIdxAB <= 100
                lbls(idxAB) = 2;
            elseif medIdxAB > 100 && medIdxAB <= 150
                lbls(idxAB) = 3;
            elseif medIdxAB > 150 && medIdxAB <= 200
                lbls(idxAB) = 4;
            elseif medIdxAB > 200 && medIdxAB <= 250
                lbls(idxAB) = 5;
%             elseif medIdxAB > 250 && medIdxAB <= 300
%                 lbls(idxAB) = 6;
%             elseif medIdxAB > 300 && medIdxAB <= 350
%                 lbls(idxAB) = 7;
%             elseif medIdxAB > 350 && medIdxAB <= 400
%                 lbls(idxAB) = 8;
%             elseif medIdxAB > 400 && medIdxAB <= 450
%                 lbls(idxAB) = 9;
%             elseif medIdxAB > 450 && medIdxAB <= 500
%                 lbls(idxAB) = 10;
%             elseif medIdxAB > 500 && medIdxAB <= 550
%                 lbls(idxAB) = 11;
            end
        end
    end
end

