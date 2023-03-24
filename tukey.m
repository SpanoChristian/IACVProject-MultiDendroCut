function y = tukey(x,c)
%UNTITLED Summary of this function goes here
%   parametro c

y =(1-(1-(x./c).^2).^3);

y(x>c)=1;

end

%%
% close all
% plot(a,  1-tukey(a,1), 'm')
% hold on
% plot(a, exp(-a), 'b')
% plot(a, 1- tanh(a), 'k')
% plot(a,  1./(1+a.^2), 'r')
% plot(a, exp(-a.^2), 'g')
% legend('tukey', 'exp-', 'tanh', 'geman', 'gauss' )