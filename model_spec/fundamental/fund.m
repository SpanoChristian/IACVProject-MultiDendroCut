function [ F ] = fund( x,y )
%FUND Compute the fundamental matrix from npoints pair of correspondence x,y.
%   INPUT:  
%           x a 3xnpoints matrix of homogeneous points
%           y a 3xnpoints matrix of homogeneous points
%   OUTPUT: 
%           if npoints=7 F is a cell array containing from 1 to 3 vectorize solution for F 
%           if npoints>=8 F is the vectorize fundamental matrix fitting the data
%
% Author: Luca Magri 2013

npoints= size(x,2);
%Tx=eye(3);
%Ty=eye(3);

%standardization of points:
[Tx,xN]=precond2(x(1:2,:));
x(:,:)=[xN;ones(1,npoints)];
[Ty,yN]=precond2(y(1:2,:));
y(:,:)=[yN;ones(1,npoints)];

for i=1:npoints
    A(i,:) = kron(x(:,i)',y(:,i)');
end
%cond(A);
[~,~,v] = svd(A);
FF{1} = reshape(v(:,end-1),[3 3]);
FF{2} = reshape(v(:,end  ),[3 3]);
if(npoints>=8)
    [u,s,v] = svd(FF{2});
    s(3,3)=0;
    f=u*s*v';
    f= Ty'*f*Tx;
    F=f(:);
elseif(npoints==7)
    
    e=FF{1};
    g=FF{2};
    
    c(4)=e(1, 1)*e(2, 2)*e(3, 3)-e(1, 1)*e(2, 3)*e(3, 2)+e(2, 1)*e(3, 2)*e(1, 3)-e(2, 1)*e(1, 2)*e(3, 3)+e(3, 1)*e(1, 2)*e(2, 3)-e(3, 1)*e(2, 2)*e(1, 3);
    
    c(1)= +g(1, 1)*g(2, 2)*g(3, 3)-g(1, 1)*g(2, 3)*g(3, 2)+g(2, 1)*g(3, 2)*g(1, 3)-g(2, 1)*g(1, 2)*g(3, 3)+g(3, 1)*g(1, 2)*g(2, 3)-g(3, 1)*g(2, 2)*g(1, 3);
    
    c(2)= +e(1, 1)*g(2, 2)*g(3, 3)-e(1, 1)*g(2, 3)*g(3, 2)+g(1, 1)*e(2, 2)*g(3, 3)+g(1, 1)*g(2, 2)*e(3, 3)-g(1, 1)*e(2, 3)*g(3, 2)-g(1, 1)*g(2, 3)*e(3, 2)+e(2, 1)*g(3, 2)*g(1, 3)-e(2, 1)*g(1, 2)*g(3, 3)+g(2, 1)*e(3, 2)*g(1, 3)+g(2, 1)*g(3, 2)*e(1, 3)-g(2, 1)*e(1, 2)*g(3, 3)-g(2, 1)*g(1, 2)*e(3, 3)+e(3, 1)*g(1, 2)*g(2, 3)-e(3, 1)*g(2, 2)*g(1, 3)+g(3, 1)*e(1, 2)*g(2, 3)+g(3, 1)*g(1, 2)*e(2, 3) -g(3, 1)*e(2, 2)*g(1, 3)-g(3, 1)*g(2, 2)*e(1, 3);
    
    c(3)=+e(1, 1)*e(2, 2)*g(3, 3)+e(1, 1)*g(2, 2)*e(3, 3)-e(1, 1)*e(2, 3)*g(3, 2)-e(1, 1)*g(2, 3)*e(3, 2) +g(1, 1)*e(2, 2)*e(3, 3)-g(1, 1)*e(2, 3)*e(3, 2)+e(2, 1)*e(3, 2)*g(1, 3)+e(2, 1)*g(3, 2)*e(1, 3)-e(2, 1)*e(1, 2)*g(3, 3)-e(2, 1)*g(1, 2)*e(3, 3)+g(2, 1)*e(3, 2)*e(1, 3)-g(2, 1)*e(1, 2)*e(3, 3)+e(3, 1)*e(1, 2)*g(2, 3)+e(3, 1)*g(1, 2)*e(2, 3)-e(3, 1)*e(2, 2)*g(1, 3)-e(3, 1)*g(2, 2)*e(1, 3)+g(3, 1)*e(1, 2)*e(2, 3)-g(3, 1)*e(2, 2)*e(1, 3);
    
    a=roots(c);
    numSol=0;
    F=zeros(9,3);
    for i= 1:length(a)
        if isreal(a(i))
            numSol=numSol+1;
            f = e+a(i)*g;
            f=Ty'*f*Tx;
            F(:,numSol)=f(:);
        end
    end
    F=F(:,numsol);
else
    warning('for estimating fundamental matrix at least 7 points are required')
end


end

