function [ H ] = hpFundamental( X,S)
%HPFUNDAMENTAL Summary of this function goes here
%   Detailed explanation goes here
m=size(S,1);
 H=zeros(9,3*m); % preallocating for speed
        cont=1;
        for i=1:m
            x=X(1:3,S(i,:));
            y=X(4:6,S(i,:));
            if(any(x(3,:)==0)|| any(y(3,:)==0))
                F=rand(9,1);
            else
                F=fund(x,y);
            end
            numSol=size(F,2);
            %for each mss estimate n fm, where n ranges from 1 to 3;
            for j=1:numSol
                H(:,cont)=F(:,j);
                cont=cont+1;
            end
            
        end
        
        H=H(:,1:cont-1); % taking into account only generated hp.
end

