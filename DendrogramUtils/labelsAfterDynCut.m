function lbls = labelsAfterDynCut(X, tree, AltB)
%LABELSAFTERDYNCUT assign cluster to points
% Inputs
%   X: list of points
%   tree: tree obtained from the dendrogram
%   AltB: name of clusters that are better merged than splitted
% Outputs
%   lbls: for each point, it says the label it has been assigned to

    sizeAltB = length(AltB);
    lbls = zeros(length(X), 1);
    l = 0;
    
    for i = 1:sizeAltB
        idxAB = get_cluster_idxPoints(AltB(i), X, tree);
        P = get_cluster_points(X, idxAB);
        % With circles I used: 18
        if length(P) > 25
            l = l + 1;
            lbls(idxAB) = l;
%             medIdxAB = median(idxAB);
            % Just for the purpose of theoretical results we do this
            % In practice it does not make any sense and we should just
            % rely on ARI and NMI
%             if medIdxAB > 0 && medIdxAB <= 50
%                 lbls(idxAB) = 1;
%             elseif medIdxAB > 50 && medIdxAB <= 100
%                 lbls(idxAB) = 2;
%             elseif medIdxAB > 100 && medIdxAB <= 150
%                 lbls(idxAB) = 3;
%             elseif medIdxAB > 150 && medIdxAB <= 200
%                 lbls(idxAB) = 4;
%             elseif medIdxAB > 200 && medIdxAB <= 250
%                 lbls(idxAB) = 5;
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
            %end
        end
    end
    
    pts50 = lbls(1:50);
    pts100 = lbls(51:100);
    pts150 = lbls(101:150);
    pts200 = lbls(151:200);
    pts250 = lbls(201:250);
    pts300 = lbls(251:300);
    pts350 = lbls(301:350);
    pts400 = lbls(351:400);
    pts450 = lbls(401:450);
    pts500 = lbls(451:500);
    pts550 = lbls(501:550);

    [mode50, n50] = mode(pts50(pts50 ~= 0));
    %disp("Mode 1-50pts : " + mode50 + " - " + n50)
    [mode100, n100] = mode(pts100(pts100 ~= 0));
    %disp("Mode 51-100pts : " + mode100 + " - " + n100)
    [mode150, n150] = mode(pts150(pts150 ~= 0));
    %disp("Mode 101-150pts : " + mode150 + " - " + n150)
    [mode200, n200] = mode(pts200(pts200 ~= 0));
    %disp("Mode 151-200pts : " + mode200 + " - " + n200)
    [mode250, n250] = mode(pts250(pts250 ~= 0));
    %disp("Mode 201-250pts : " + mode250 + " - " + n250)
    [mode300, n300] = mode(pts300(pts300 ~= 0));
    %disp("Mode 251-300pts : " + mode300 + " - " + n300)
    [mode350, n350] = mode(pts350(pts350 ~= 0));
    %disp("Mode 301-350pts : " + mode350 + " - " + n350)
    [mode400, n400] = mode(pts400(pts400 ~= 0));
    %disp("Mode 351-400pts : " + mode400 + " - " + n400)
    [mode450, n450] = mode(pts450(pts450 ~= 0));
    %disp("Mode 401-450pts : " + mode450 + " - " + n450)
    [mode500, n500] = mode(pts500(pts500 ~= 0));
    %disp("Mode 451-500pts : " + mode500 + " - " + n500)
    [mode550, n550] = mode(pts550(pts550 ~= 0));
    % disp("Mode 501-550pts : " + mode550 + " - " + n550)
    % 
    lblsNew = zeros(length(lbls), 1);
    lblsNew(find(lbls == mode50)) = 1;
    lblsNew(find(lbls == mode100)) = 2;
    lblsNew(find(lbls == mode150)) = 3;
    lblsNew(find(lbls == mode200)) = 4;
    lblsNew(find(lbls == mode250)) = 5;
    lblsNew(find(lbls == mode300)) = 6;
    lblsNew(find(lbls == mode350)) = 7;
    lblsNew(find(lbls == mode400)) = 8;
    lblsNew(find(lbls == mode450)) = 9;
    lblsNew(find(lbls == mode500)) = 10;
    lblsNew(find(lbls == mode550)) = 11;

    lbls = lblsNew;
end

