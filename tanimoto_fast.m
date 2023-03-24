function d = tanimoto_fast( XI,XJ )
%TANIMOTO taking as arguments a 1-by-n vector XI, corresponding to a single
%row of X, and an m2-by-n matrix XJ, corresponding to multiple rows of X.
%tanimoto must accept a matrix XJ with an arbitrary number of rows.
%tanimoto must return an m2-by-1 vector of distances d, whose kth element is the distance between XI and XJ(k,:)
%
% Author: Luca Magri
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it
% November 2017 Marco Patane' fast version

s = XJ*XI';
d = 1 - s./(XI*XI'+sum(XJ.^2,2)-s);
d = d.*(~all(XI==XJ,2));
% assert(all(d)>=0)

end
