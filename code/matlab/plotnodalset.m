function plotnodalset(u)
%
%   function plotnodalset(u)
%

set(0,'defaultaxesfontsize',20,'defaultaxeslinewidth',2,...
    'defaultlinelinewidth',2);

% Find positive and negative values

ub = -0.5 - 0.3 * (2.0 * (u>0.0) - 1.0);

pcolor(ub);
shading interp;
caxis([-1 1]);
axis off;
axis equal;
