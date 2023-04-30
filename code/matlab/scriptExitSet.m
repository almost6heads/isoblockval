clear;
clear all;
clear session;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%   This script demonstrates the validation of exit sets using         %
%   the Hopf bifurcation example from Section 4.3.                     %
%                                                                      %
%   For the isolating block C1, it validates the exit set using the    %
%   subdivision algorithm, and also creates images which show the      %
%   nodal domains of both the exitset test function u and the          %
%   modified tangency test function w, together with the zero set of   %
%   the respective other function.                                     %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set graphics parameters

set(0,'defaultaxesfontsize',20,'defaultaxeslinewidth',2,...
    'defaultlinelinewidth',2);

Nplot = 1024;

% Define function handles for u and w

fct_handle  = @eval_c1u;
fct_handle2 = @eval_c1w;

% Define the bounding box

x0 = 0.0;
x1 = 2.0*pi;
y0 = 0.0;
y1 = pi;
x  = infsup(x0,x1);
y  = infsup(y0,y1);

% Validate the exit set using the subdivision algorithm

[vflag,vboxes] = validatenodalset(fct_handle,x,y,1);
[Nd,Nb]        = size(vboxes);

if vflag==1
    fprintf('\n');
    fprintf(' Exit set validated with %d boxes. \n', Nb);
    fprintf('\n');
else
    fprintf('\n');
    fprintf(' Exit set did not validate. \n');
    fprintf('\n');
end;

% Save the image of the final domain decomposition

axis([x0,x1,y0,y1]);
title('Validation grid for the nodal domains of u');
drawnow;
print('-djpeg100','scriptExitSet1.jpg');

% Numerically determine the function values of u and w over the box.
% These values are stored in uu and ww. The variables uub and wwb 
% contain thresholded versions so that positive function values
% correspond to dark blue and negative function values to light blue
% in subsequent pcolor plots.

xp = linspace(x0,x1,Nplot);
yp = linspace(y0,y1,Nplot);

[xx,yy] = meshgrid(xp,yp);
uu  = fct_handle(xx,yy);
uub = -0.5 - 0.3 * (2.0 * (uu>0.0) - 1.0);
ww  = fct_handle2(xx,yy);
wwb = -0.5 - 0.3 * (2.0 * (ww>0.0) - 1.0);

% Plot the nodal domains of the exit set test function u in dark blue,
% together with the zeros of the tangency function w in black, and the 
% boxes from the validation of the exit set in red.

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
    xk1 = vboxes(1,k);
    xk2 = vboxes(2,k);
    yk1 = vboxes(3,k);
    yk2 = vboxes(4,k);
    plot([xk1, xk2, xk2, xk1, xk1],[yk1, yk1, yk2, yk2, yk1],'r');
end;

title('Nodal domains of u');
drawnow;
print('-djpeg100','scriptExitSet2.jpg');

% Plot the nodal domains of the modified tangency test function w,
% together with the zeros of the exit set function u.

figure;
pcolor(xp,yp,wwb);
hold on;
contour(xp,yp,uu,[0.0,0.0],'k','LineWidth',2);
axis([x0,x1,y0,y1]);
caxis([-1 1]);
shading interp;
axis off;
title('Nodal domains of w');
drawnow;
print('-djpeg100','scriptExitSet3.jpg');
