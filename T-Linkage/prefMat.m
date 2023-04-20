function  P  = prefMat( R, epsilon, r )
%
% prefMat Estimate the preference matrix frome the residual matrix using
% a voting procedure specified by r.
% 
% INPUT:
%       R: residual matrix: the entry (i,j) is the residual between the i-th
%       point and the j-th model
%       epsilon: threshold value
%       r: specifies the voting scheme:
%           r=1 exponential voting
%           r=2 gaussian voting
%           r=0 hard voting
%
%OUTPUT:
%       P: preference matrix, each row depicts points preferences with
%       repsect to the putative model hypotheses
%
% Author: Luca Magri
% For any comment, question or suggestion about the code please contact
% luca (dot) magri (at) unimi (dot) it


[n,m]=size(R);
%initialize Preference Matrix
P=zeros(n,m);
%set cutoff value
if nargin==2
    r=1;
    disp('Exponential voting is used')
end

switch r
    case 0
        disp('Hard voting')
        I=R<epsilon;
        P(I) = 1;
    case 1
        disp('Exponential voting')
        tau=epsilon/5;
        I=R<epsilon;
        P(I) = exp(-R(I)./tau);
    case 2
        disp('Gaussian voting')
        sigma=epsilon/4;
        I=R<epsilon;
        P(I) = exp(-(R(I).^2)./(sigma^2));
    case 3
        disp('Tukey voting')
        I=R<epsilon;
        P(I) = 1-tukey(R(I),epsilon);
end




end

