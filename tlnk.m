function [ C, T ] = tlnk(P, D)
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

[C, ~, ~] = grp2idx(C);

% pts50 = C(1:50);
% pts100 = C(51:100);
% pts150 = C(101:150);
% pts200 = C(151:200);
% pts250 = C(201:250);
% % pts300 = C(251:300);
% % pts350 = C(301:350);
% % pts400 = C(351:400);
% % pts450 = C(401:450);
% % pts500 = C(451:500);
% % pts550 = C(501:550);
% 
% [mode50, n50] = mode(pts50);
% %disp("Mode 1-50pts : " + mode50 + " - " + n50)
% [mode100, n100] = mode(pts100);
% %disp("Mode 51-100pts : " + mode100 + " - " + n100)
% [mode150, n150] = mode(pts150);
% %disp("Mode 101-150pts : " + mode150 + " - " + n150)
% [mode200, n200] = mode(pts200);
% %disp("Mode 151-200pts : " + mode200 + " - " + n200)
% [mode250, n250] = mode(pts250);
% %disp("Mode 201-250pts : " + mode250 + " - " + n250)
% % [mode300, n300] = mode(pts300);
% % %disp("Mode 251-300pts : " + mode300 + " - " + n300)
% % [mode350, n350] = mode(pts350);
% % %disp("Mode 301-350pts : " + mode350 + " - " + n350)
% % [mode400, n400] = mode(pts400);
% % %disp("Mode 351-400pts : " + mode400 + " - " + n400)
% % [mode450, n450] = mode(pts450);
% % %disp("Mode 401-450pts : " + mode450 + " - " + n450)
% % [mode500, n500] = mode(pts500);
% % %disp("Mode 451-500pts : " + mode500 + " - " + n500)
% % [mode550, n550] = mode(pts550);
% %disp("Mode 501-550pts : " + mode550 + " - " + n550)
% % 
% Cnew = C;
% Cnew(find(C == mode50)) = 1;
% Cnew(find(C == mode100)) = 2;
% Cnew(find(C == mode150)) = 3;
% Cnew(find(C == mode200)) = 4;
% Cnew(find(C == mode250)) = 5;  
% % Cnew(find(C == mode300)) = 6;
% % Cnew(find(C == mode350)) = 7;
% % Cnew(find(C == mode400)) = 8;
% % Cnew(find(C == mode450)) = 9;
% % Cnew(find(C == mode500)) = 10;
% % Cnew(find(C == mode550)) = 11;
% 
% C = Cnew;