function [max, min] = getMaxMinDistance(X)
%GETMAXMINDISTANCE given a the set of points, compute max and min euclidean
% distance
    
    numberOfPoints = size(X,2);
    min = euclideanDistance(X(:, 1), X(:, 2));
    max = min;
    for i=1:numberOfPoints - 1
        for j = i+1:numberOfPoints
            distance = euclideanDistance(X(:,i), X(:,j));
            if distance < min
                min = distance;
            end

            if distance > max
                max = distance;
            end
        end
    end

    
end

