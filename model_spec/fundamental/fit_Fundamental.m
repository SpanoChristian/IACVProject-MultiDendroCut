function [ M ] =fit_Fundamental( X, Cs)
%RANSAC_FIT Summary of this function goes here
%   Detailed explanation goes here

label=unique(Cs);
N=length(label); %numero di cluster;
f=size(X,1);
cardmss=4;
M=nan(9,N);

for i=1:N
    
    L  = label(i);
    %if(sum(Cs==L)>8)
        points2fit = X(:,Cs==L);
        x=points2fit(1:3,:);
        y=points2fit(4:6,:);
        M(:,i)=fund(x,y);
    %end
end


