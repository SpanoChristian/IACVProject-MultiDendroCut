function [ C ,T ] = tlnk_fast(P,D)
% TLNK T-Linkage clustering function
% INPUT:
%        P preference matrix
%        D tanimoto distance matrix
%        n number of desidered clusters
% OUTPUT:
%       C clustering labeling vector
%       T clustering dendrogram 


%
% The Software is provided "as is", without warranty of any kind.
% For any comment, question or suggestion about the code please contact
% magri.luca.l@gmail.com
%
% Author: Luca Magri
% July  2014  Original version
% November 2017 Marco Patane' fast version

n = size(P,1);
if (nargin<2 || isempty(D))
    D = squareform(pdist(P,@tanimoto_fast)) + diag(Inf*ones(n,1)); %calculating distances
end

flg = 1:n; %flag
T = zeros(n-1,3); %linkage tree
k = 1; %iterations
[dmin,index] = min(D(:));
Tmap = 1:n;
while dmin<1 
    [x,y] = ind2sub([n,n],index);
    
    T(k,1) = Tmap(x); T(k,2) = Tmap(y); T(k,3) = dmin;
    %updating preferences
    P(x,:) = min(P(x,:),P(y,:));
    flg = setdiff(flg,y);
    Tmap(x) = n+k;
    
    %updating distances:  
    %1 removing distances between y
    D(y,:) = Inf;
    D(:,y) = D(y,:);
    
    %2 updating distances with x
    flgx = setdiff(flg,x);
    D(x,flgx) = tanimoto_fast(P(x,:),P(flgx,:));
    D(flgx,x) = D(x,flgx);
    
    [dmin,index] = min(D(:));
    k = k+1;
end
%figure; dendrogram(T)

%G=cluster(T,'cutoff',1-(1/(size(P,1)))+eps,'criterion','distance');

% the number of cluster is automatically estimated by T-linkage
t = size(T,1);
C = (1:n)';
for j = 1:t
    if(T(j,3)<1-eps)
        a = T(j,1); b = T(j,2);

        %E1 = find(C==a); E2 = find(C==b);
        %C(E1) = n+j;
        %C(E2) = n+j;

        C(C==a|C==b)=n+j;
    end
end

[C,~,~]=grp2idx(C);
