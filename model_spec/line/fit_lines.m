function [ M ] = fit_lines( X,Cs)
%RANSAC_FIT Summary of this function goes here
%   Detailed explanation goes here

label=sort(unique(Cs));
N=length(label); %numero di cluster;
M=nan(3,N);



for i=1:N
    
    L  = label(i);
    points2fit = X(:,Cs==L);
    U = fitline(points2fit);
    M(:,i)=U';
end


% % % % % % % % % % % % % % % for i=1:N
% % % % % % % % % % % % % % %     L=label(i);
% % % % % % % % % % % % % % %     points2fit=X(:,Cs==L);
% % % % % % % % % % % % % % %         size(points2fit)
% % % % % % % % % % % % % % %         n = size(points2fit,2);
% % % % % % % % % % % % % % %         A = [points2fit;ones(1,n)];
% % % % % % % % % % % % % % %         size(A)
% % % % % % % % % % % % % % %         [U,~,~]=svd(A');
% % % % % % % % % % % % % % %         U(:,end)
% % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % %         M=[M, U(:,end)];
% % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % % % % %     
% % % % % % % % % % % % % % % % % % % % % % % %     
% % % %     p=polyfit(points2fit(1,:),points2fit(2,:),1);
% % % %     if(p(1)>1e+5)
% % % %         c=mean(points2fit(1,:));
% % % %         %p=[c;0;0];
% % % %         M= [M, [1 0 -c]];
% % % %     else
% % % %         M=[M, [p(1);-1;p(2)]];
% % % %     end
% % % %     
    
 


