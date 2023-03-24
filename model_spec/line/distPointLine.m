function [ d ] = distPointLine( P,l )
%DISTPOINTLINE calcola la distanza euclidea tra un punto P e una retta l
%   Detailed explanation goes here

d=abs(l(1)*P(1)+l(2)*P(2)+l(3))/sqrt(l(1)^2+l(2)^2);

end

