function [ X ] = generate_Circles( num, points, radius, epsilon )
%GENERATE_CIRCLES generate circles: number of points is uniform in density
%   Detailed explanation goes here

X = zeros(2,num*points);
C = [4*rand(1,num);4*rand(1,num)]; %centers
T = rand(num,points)*2*pi;
cont = 1;
for i = 1:num
    for j = 1:points
    X(:,cont) = C(:,i) + [radius*cos(T(i,j)); radius*sin(T(i,j))];
    cont = cont+1;
    end
end
X=X+randn(2,num*points).*epsilon;  

end


