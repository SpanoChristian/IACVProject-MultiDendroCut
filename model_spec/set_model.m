function [ distFun, hpFun, fit_model, cardmss   ] = set_model( model )
%SET_MODEL set the model specification: possible models are 'line', 'circle',
% fundamental matrices ('fundamental') and 'subspace4'.
%
% OUTPUT:
% distFun: evaluates the distances between points and model,
% hpFun: genrate the hypothesis function using
% points with minimal sample cardinality (cardmss),
% fit_model: fits models to set of points with cardinality equal or larger than
% cardmss



switch model
    case 'line'
        distFun = @distPointLine;
        hpFun = @hpLines;
        fit_model = @fit_lines;
        cardmss = 2;
    case 'circle'
        distFun = @distPointCircle;
        hpFun = @hpCircles;
        fit_model = @fit_circles;
        cardmss = 3;
    case 'fundamental'
        distFun = @distPointFm;
        hpFun = @hpFundamental;
        fit_model = @fit_Fundamental;
        cardmss = 8;
    case 'subspace4'
        distFun = @distPointSubspace4;
        hpFun = @hpSubspace4;
        fit_model = @fit_Subspace4;
        cardmss = 4;
    otherwise
        warning('model not yet supported: possible models are line, circle, homography, fundamental, subspace4')
end



end

