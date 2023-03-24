function S = mssUniform(X, m, cardmss)
%create minimal sample set indices via uniform sampling
%
%INPUT:
%       X: (d x n) matrix containing n data points arranged by columns
%       m: desired number of samples
%       cardmss: cardinality of minimal sample set.
%
%OUTPUT:
%S: (m x cardmss) matrix containing the inidces of the generate mss 

% Author: Luca Magri

n=size(X,2);


%% Cumulative distribution

F = zeros(n);

for i = 1:n
    t = [0:n-1];
    F(i,:) = t./t(end);
end

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
            
            newi=k;
            S(i,j)=newi;
            flg=ismember(newi,S(i,1:j-1)); % if newi is already in mss repeat
            
        end
    end
end

%% check for repeated mss:
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
