function [ d ] = distPointFm( x,H )
%DISTPOINTLINE compute the euclidean distance between a point x and an
%hyperplane H
%   Detailed explanation goes here
F=reshape(H,3,3);
m1=x(1:2,:);
m2=x(4:5,:);

d = sampson(F, m1, m2);
end

