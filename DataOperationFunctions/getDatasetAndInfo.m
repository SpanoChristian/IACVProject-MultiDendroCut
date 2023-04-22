function [X, G, numTotalPoints, numToClusterizePoints, numOutliers, numClusters, title] = getDatasetAndInfo(hasGroundTruth ,selectedDataset)
%GETDATASETINFO 
%   If hasGroundTruth is false, then specify the dataset
%   otherwise it will choose the only available with a ground truth
    
    if ~hasGroundTruth

        load './Dataset/JLinkageExamples.mat'
        
        switch selectedDataset 
            case 1
                X = Star5_S0015_O0;
                numTotalPoints = 250;
                numToClusterizePoints = numTotalPoints;
                numClusters = 5;
                title ="Star5_S0015_O0";
            case 2
                X = Star5_S0015_O50;
                numTotalPoints = 500;
                numToClusterizePoints = 250;
                numClusters = 5;
                title ="Star5_S0015_O50";
            case 3
                X = Star5_S00075_O0;
                numTotalPoints = 250;
                numToClusterizePoints = numTotalPoints;
                numClusters = 5;
                title ="Star5_S00075_O0";
            case 4
                X = Star5_S00075_O50;
                numTotalPoints = 500;
                numToClusterizePoints = 250;
                numClusters = 5;
                title ="Star5_S00075_O50";
            case 5
                error('in getDatasetAndInfo case 5')
                X = Star5_S00075_O75;
                numTotalPoints = 750;
                numToClusterizePoints = 550;
                numClusters = 5;
                title ="Star5_S00075_O75";
            case 6
                X = Star11_S00075_O0;
                numTotalPoints = 550;
                numToClusterizePoints = 550;
                numClusters = 11;
                title ="Star11_S00075_O0";
            case 7
                X = Star11_S00075_O50;
                numTotalPoints = 1100;
                numToClusterizePoints = 550;    
                numClusters = 11;
                title ="Star11_S00075_O50";
        end
        G=[];
    else
        load './Dataset/Star5.mat';
        numTotalPoints = size(X, 2);
        numToClusterizePoints = size(find(G),1);
        numClusters = 5;
        title ="Star5 With GT";
        
    end

    numOutliers = numTotalPoints - numToClusterizePoints;
end