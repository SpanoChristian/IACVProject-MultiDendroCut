function [ H ] = hpLines( X,S )
%GENERATEHYPOTESISLINES generate lines hp.
%   IDEA genero le m ipotesi, 

% Le ipotesi le rappresento con vettori colonna.
m=size(S,1);
H=zeros(3,m); 
for i=1:m
    a=[X(:,S(i,1));1];
    b=[X(:,S(i,2));1];
    H(:,i)= cross(a,b); %coefficienti della retta passante per a e b
    
    
end



