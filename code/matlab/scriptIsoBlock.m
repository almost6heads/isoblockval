clear;
clear all;
clear session;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%   This script demonstrates the validation of an isolating block      %
%   using the Hopf bifurcation example from Section 4.3.               %
%                                                                      %
%   For the isolating block C1, it uses the function validateisoblock  %
%   to create a randomized rectangular subdivision of the domain       %
%   which validates the exit set as described by u, and such that      %
%   on every rectangle which intersects the zero set of u the test     %
%   function w is positive.                                            %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set graphics parameters

set(0,'defaultaxesfontsize',20,'defaultaxeslinewidth',2,...
    'defaultlinelinewidth',2);

Nplot = 1024;

% Define function handles for u and w

fct_handle   = @eval_c1u;
fct_handle_t = @eval_c1w;

% Define the bounding box

x0 = 0.0;
x1 = 2.0*pi;
y0 = 0.0;
y1 = pi;
x  = infsup(x0,x1);
y  = infsup(y0,y1);

% Validate the isolating block using the subdivision algorithm
% This routine has been slightly modified to save the final domain
% decomposition after the exit set validation, for comparison purposes.

[vflag,vboxes] = validateisoblock(fct_handle,fct_handle_t,x,y,1);
[Nd,Nb]        = size(vboxes);

% Save the image of the final domain decomposition

axis([x0,x1,y0,y1]);
drawnow;
print('-djpeg100','scriptIsoBlock2.jpg');

% Numerically determine the function values of u and w over the box.
% These values are stored in uu and ww. The variable uub contains a
% thresholded version of uu so that positive function values correspond
% to dark blue and negative function values to light blue in the
% subsequent pcolor plot.

xp = linspace(x0,x1,Nplot);
yp = linspace(y0,y1,Nplot);

[xx,yy] = meshgrid(xp,yp);
uu  = fct_handle(xx,yy);
uub = -0.5 - 0.3 * (2.0 * (uu>0.0) - 1.0);
ww  = fct_handle_t(xx,yy);

% Plot the nodal domains of the exit set test function u in dark blue,
% together with the zeros of the tangency function w in black, and the 
% boxes from the validation of the isolating block in red.

figure;
pcolor(xp,yp,uub);
hold on;
contour(xp,yp,ww,[0.0,0.0],'k','LineWidth',2);
axis([x0,x1,y0,y1]);
caxis([-1 1]);
shading interp;
axis off;
hold on;

for k=1:Nb
    x1 = vboxes(1,k);
    x2 = vboxes(2,k);
    y1 = vboxes(3,k);
    y2 = vboxes(4,k);
    plot([x1, x2, x2, x1, x1],[y1, y1, y2, y2, y1],'r');
end;

drawnow;
print('-djpeg100','scriptIsoBlock3.jpg');
