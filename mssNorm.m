function S = mssNorm( X, D, m,cardmss, mu, sigma)
%create minimal sample set indices via normal sampling
%
%INPUT:
%       X: (d x n) matrix containing n data points arranged by columns
%       D: (n x n) distance matrix       
%       m:  desired number of samples
%       cardmss: cardinality of minimal sample set
%       mu:      average
%       sigma:   variance
%
%OUTPUT:
%       S:       (m x cardmss) matrix containing the inidces of the generate mss 
%
% Author: Luca Magri

if nargin<6
    sigma=max(D(:))/4;
    if nargin==4
        mu=0;
    end
end

n=size(X,2);

% 
% D = pdist(X','euclidean');
% %dmax=max(D);
% D = squareform(D);

O = zeros(n,n-1); %index
sD = zeros(n,n-1); % submatrix of distances
ii = 1:n;

for p = 1:n
    O(p,:) = ii(ii~=p);
    sD(p,:) = D(p,O(p,:));
end

%out=(sD>=dmax/2); %distance grater than dIm/k are forced to have null probability


%spy(sD)


%% Normal distribution


%sigma = dmax/6; %   12
%tau=dIm/10;

N = (1/sqrt(2*pi*sigma^2)).*exp(-(sD-mu).^2./sigma^2);
%N=exp(-sD./tau);
%N(out)=0;



%% plot

% dbg=false;
% 
% if(dbg)
%     for p = 1:1
%         figure(2)
%         bar(N(p,:))
%         pause(0.5)
%     end
% end




%% Cumulative distribution

F = zeros(n-1);

for i = 1:n
    t = cumsum(N(i,:));
    F(i,:) = t./t(end);
end

% if(dbg)
%     for p = 1:1
%         figure(3)
%         stairs(F(p,:),'r')
%         hold on
%         pause(0.5)
%     end
% end
%% Generating mss


S=zeros(m,cardmss);

% first elements of each mss are taken ciclying on data
for i = 1:m
    if(mod(i,n)==0)
        S(i,1) = n;
    else
        S(i,1) = mod(i,n);
    end
end


for i = 1:m
    p = S(i,1);
    
    for j = 2:cardmss
        flg=true;
        while(flg)
            dice=rand(1,1);
            k=find(F(p,:)>dice, 1 ,'first');
           
            newi=O(p,k);
            S(i,j)=newi;
            flg=ismember(newi,S(i,1:j-1)); % if newi is already in mss repeat
            
        end
    end
end

%% check for repeated mss:
if(0)
Snew=sort(S,2);
R=true(m,1);
cont=0;
for i=1:m
    if(ismember(Snew(i+1:end,:),Snew(i,:),'rows'))
        R(i)=false;
        cont=cont+1;
    end
end
S=S(R,:);
if(cont~=0)
    fprintf('%i mss discarded\n',cont);
end
end




%%
% if(dbg)
%     for p =1:10
%         figure
%         scatter(X(1,:),X(2,:));
%         hold on
%         scatter(X(1,S(p,1)),X(2,S(p,1)),'r','*')
%         hold on
%         scatter(X(1,S(p,2:5)),X(2,S(p,2:5)),'k','*')
%         pause(0.4)
%         
%         hold off
%     end
% end
