function gScore = getGricScore(Xi, lambda, numberTotalPoints)
%GETGRICSCORE the higher the worse
    
   
    if size(Xi,2) >= 2
        mi = fitline(Xi);
        ri = res_line(Xi, mi);
    else
        ri = 10;
        %display("Entered else Xi")
    end
    rSqr = ri.^2;
    n = numel(rSqr);
%{
    if n > 2
        % better if getMaxMinDistance(Xi) computed once
        % the idea is that according to the model, we have a different distance
        % measure
        [maxDistance, minDistance] = getMaxMinDistance(Xi); 
    else
        maxDistance = 0;
        minDistance = 1;
    end
%}
    dataFidelity = min(mean(rSqr, 'omitnan'), 100);
    modelComplexity = 1/(exp(-(((n)/(lambda)))^(2)));
    %modelComplexity = 10/(exp(-(((n-lambda1)/(lambda2)))^(2))+(1/10));
    %modelComplexity = 0.1*(n - lambda)^2;
    gScore = dataFidelity + modelComplexity;

end


