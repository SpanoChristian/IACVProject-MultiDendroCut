function [ C, T ] = tlnk(P,D)
% TLNK T-Linkage clustering function
% INPUT: 
%        P preference matrix
%        D tanimoto distance matrix
% OUTPUT
%       C clustering vector:
%       T linkage matrix
    
    
    %
    % The Software is provided "as is", without warranty of any kind.
    % For any comment, question or suggestion about the code please contact
    % luca.magri@unimi.it
    %
    % Author: Luca Magri
    % July   2014  Original version
    
    
    if (nargin==1)
        D = pdist(P,@tanimoto); %calculating distances
    else
        D = squareform(D);
    end
    
    [n, c]= size(P);
    PP=[P; zeros(n,c)];
    
    
    N = length(D);
    m = ceil(sqrt(2*N));
    I=1:N;
    U = m - round( sqrt( 2*(1 + N - I) ) );
    V = mod(I + U.*(U+1)/2 - 1, m) + 1;
    
    flg= true(1,N); %flag
    T = zeros(n-1,3); %linkage tree
    k = 1; %iterations
    Dtemp = D(flg);
    %dmin=0;
    while (any(flg)) %while(dmin<1)    %while(k<=n-1)        %while(~all(Dtemp==1))
        % find minimum distance, x, y
        dmin = min(Dtemp);
        index = find(Dtemp==dmin);
        index=index(1);
        Utemp=U(flg);
        Vtemp=V(flg);
        x = Utemp(index);
        y = Vtemp(index);
        
        T(k,1) = x; T(k,2) = y; T(k,3)=dmin;
        
        %updating preferences
        pnew = min(PP(x,:) , PP (y,:)); %sqrt(PP(x,:) .* PP (y,:)); % new pewference set
        PP(n+k,:) = pnew;
        
        %updating distances:
        %1 removing distances between y
        Uy = (U==y);
        Vy = (V==y);
        flg((Uy|Vy)&flg) = false;
        
        
        %2 updating distances with x
        Ux = (U==x);
        Vx = (V==x);
        U(Ux &flg) = n+k;
        V(Vx &flg) = n+k;
        update = (Ux|Vx)&flg;
        col = I(update);
        for j=col
            D(j)=tanimoto(PP(U(j),:),PP(V(j),:));
        end
        Dtemp = D(flg);
        k=k+1;
        
    end
    
    %dendrogram(T, 0)
    % G = cluster(T, 'cutoff', 1-(1/(size(P,1)))+eps, 'criterion', 'distance');
    
    
    t = size(T,1);
    C = (1:n)';
    for j = 1:t
        if(T(j,3) < 1)
            a = T(j, 1); b = T(j,2);
            
            %E1 = find(C==a); E2 = find(C==b);
            %C(E1) = n+j;
            %C(E2) = n+j;
            
            C(C==a | C==b)=n+j;
        end
    end
end