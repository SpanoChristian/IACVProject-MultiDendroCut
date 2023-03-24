function [ M ] =fit_Subspace4( X, Cs)
%RANSAC_FIT Summary of this function goes here
%   Detailed explanation goes here

label=unique(Cs);
N=length(label); %numero di cluster;
f=size(X,1);
cardmss=4;
M=zeros(f*4,N);

for i=1:N
    
    L  = label(i);
    points2fit = X(:,Cs==L);
    [U,~,~]=svd(points2fit);
    U=U(:,1:4);
    M(:,i)=U(:);
end
    
    
