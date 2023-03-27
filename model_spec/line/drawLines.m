function [ ] = drawLines( M )
%DRAWLINES Summary of this function goes here
%   Detailed explanation goes here
    
    p=[-M(1)/M(2),-M(3)/M(2)];
        xx=linspace(-1,1);
        yy=polyval(p,xx);
        plot(xx,yy,'k--','Markersize',3)
end

