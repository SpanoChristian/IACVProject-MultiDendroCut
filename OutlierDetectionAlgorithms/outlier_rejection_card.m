function [ C_new ] = outlier_rejection_card( C, cardmss )
%OUTREJHIST outlier rejection based on cardinality: the rationale is that
%outliers tends to emerge as small cluster in conceptual space.
%T-Linkage is agonostic about the outlier rejection strategy adopted: some
%improvement can be obtained exploiting the randomness of a model (code will be available).
% INPUT:
%       C: clustering vector
%       cardmss: size of minimal sample set
%OUTPUT
%       C_new: clustering vector, outlier are labeled 0.
%
%
% Author: Luca Magri 2014
% For any comments, questions or suggestions about the code please contact
% luca (dot) magri (at) unimi (dot) it


lbl = sort(unique(C)); %get all cluster labels
N = length(lbl); %get number of clusters (outliers are a separate cluster)
card = zeros(1, N);
for l = 1:N %for each label
    card(l) = sum(C == lbl(l)); %%see number of points belonging to that cluster
end
card = [card, cardmss]; % add a dummy mss

lbl = [lbl; 0]; %zero appears twice
[card_sorted, v] = sort(card, 'ascend');
lbl_sorted = lbl(v);

dHist = diff(card_sorted);

[~, cut] = max(dHist); % cut is the index of value which has greatest difference from following value
C_new = C;

if cut > 1
    if cut == length(dHist)
        dHist(cut) = 0;
        [~, cut] = max(dHist);
        %disp('we assume at least 2 models in the data')
    end
    lbl_out = lbl_sorted(1:cut);
    for j = 1:cut
        w = lbl_out(j);
        C_new(C_new == w) = 0;
    end
    [C_new(C_new ~= 0), ~, ~] = grp2idx(C_new(C_new ~= 0));
end

end

