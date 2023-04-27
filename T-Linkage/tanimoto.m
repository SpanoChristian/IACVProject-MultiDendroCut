function d = tanimoto( XI,XJ )
%TANIMOTO taking as arguments a 1-by-n vector XI, corresponding to a single
%row of X, and an m2-by-n matrix XJ, corresponding to multiple rows of X.
%tanimoto must accept a matrix XJ with an arbitrary number of rows.
%tanimoto must return an m2-by-1 vector of distances d, whose kth element is the distance between XI and XJ(k,:)
%
% Author: Luca Magri
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it

r=size(XJ,1);
d=zeros(r,1);
for k=1:r
    if(all(XI==XJ(k,:)))
        d(k)=0;
    else
        s=XI*XJ(k,:)';
        d(k)=1- s/(norm(XI)^2+norm(XJ(k,:))^2-s);
    end
    assert(all(d)>=0)
end

