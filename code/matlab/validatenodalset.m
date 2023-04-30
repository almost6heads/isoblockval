function [vflag,vboxes] = validatenodalset(fct_u,x,y,varargin)
%
%   function [vflag,vboxes] = validateisoblock(fct_u, x, y ...
%                           [,showprog,xmax,ymax])
%
% This function tries to rigorously validate the nodal domains of
% a function u specified in fct_u, which is defined over a
% box x times y.
%
% Input arguments:
%
%    fct_u          Function handle for the function u.
%                   The code also needs files fct_ux.m and fct_uy.m
%                   which contain the corresponding partial derivatives.
%    x              Intval interval with the x-coordinates of the box
%    y              Intval interval with the y-coordinates of the box
%    [showprog]     1 = plot boxes as they are validated
%    [xmax]         Maximal x-length of a box in the final grid
%    [ymax]         Maximal y-length of a box in the final grid
%
% The arguments in brackets are optional. If any one of these is given,
% the ones preceding it have to be specified as well. If they are not
% specified their default values are showprog = 0, xmax = 1e6,
% and ymax = 1e6. If xmax is specified but ymax is not, then ymax=xmax
% is used.
%
% Output arguments:
%
%   vflag      1 = success, 0 = could not verify the nodal domains
%   vboxes     Matrix containing all the validated boxes. For each k
%              the entries vboxes(1:8,k) correspond to the 
%              box [x0,x1] x [y0,y1] where:
%                 vboxes(1,k) = x0
%                 vboxes(2,k) = x1
%                 vboxes(3,k) = y0
%                 vboxes(4,k) = y1
%                 vboxes(5,k) = sign of fct_e at lower left  corner
%                 vboxes(6,k) = sign of fct_e at lower right corner
%                 vboxes(7,k) = sign of fct_e at upper right corner
%                 vboxes(8,k) = sign of fct_e at upper left  corner
%

% Deal with the variable argument list

if (nargin == 3)
    showprog   = 0;
    xmax       = 1.0e6;
    ymax       = 1.0e6;
    enforcemax = false;
elseif (nargin == 4)
    showprog   = varargin{1,1};
    xmax       = 1.0e6;
    ymax       = 1.0e6;
    enforcemax = false;
elseif (nargin == 5)
    showprog   = varargin{1,1};
    xmax       = varargin{1,2};
    ymax       = varargin{1,2};
    enforcemax = true;
elseif (nargin == 6)
    showprog   = varargin{1,1};
    xmax       = varargin{1,2};
    ymax       = varargin{1,3};
    enforcemax = true;
end;

% Specify the smallest admissible box size, initialize sigma

rhomin = 1.0e-14;
sigma  = [0.5 * (sqrt(5.0) - 1.0), 0.5 * (3.0 - sqrt(5.0))];
%sigma  = [0.5, 0.5];

% Get handles for the first derivatives of the function u

fctname  = func2str(fct_u);
fctnamex = sprintf('%sx',fctname);
fctnamey = sprintf('%sy',fctname);

fct_ux = str2func(fctnamex);
fct_uy = str2func(fctnamey);

% Predefine the lists which a given maximal length

Qmax  = 10000;
Qdata = zeros(4,Qmax);
Qlen  = 0;

Vmax  = 10000;
Vdata = zeros(8,Vmax);
Vlen  = 0;

% Add the initial cube to the list

Qlen = 1;
Qdata(:,Qlen) = [inf(x); sup(x); inf(y); sup(y)];

% Initialize graphics if progress should be shown

if (showprog == 1)
    figure;
    plot([inf(x), sup(x), sup(x), inf(x), inf(x)], ...
         [inf(y), inf(y), sup(y), sup(y), inf(y)], 'k');
    %axis equal;
    axis([inf(x),sup(x),inf(y),sup(y)]);
    axis off;
    hold on;
    drawnow;
end;

% Main loop of the algorithm

while (Qlen > 0)
    
    % Remove the last box from the list Q
    
    x0 = Qdata(1,Qlen);   x1 = Qdata(2,Qlen);
    y0 = Qdata(3,Qlen);   y1 = Qdata(4,Qlen);
    
    Qlen = Qlen - 1;
    
    % Attempt to validate the box;
    
    xc = infsup(x0,x1);
    yc = infsup(y0,y1);
    
    [vbflag,vbsigns] = validatebox(fct_u,fct_ux,fct_uy,xc,yc);
    
    % If the validation attempt leads to not validated corners, exit
    
    if (vbflag == -1)
        disp('corner not validated')
        vflag  = 0;
        vboxes = [];
        return;
    end;
    
    % Determine what has to be done with the box
    
    boxvalidated = (vbflag==1);
    
    if ((enforcemax == true) && (abs(sum(vbsigns)) < 3.5))
        boxvalidated = ((vbflag==1) && (x1-x0<=xmax) && (y1-y0<=ymax));
    end;
    
    % Two main alternatives
    
    if (boxvalidated == true)
        
        % The box validated, add it to the list V
        
        Vlen = Vlen + 1;
        Vdata(:,Vlen) = [x0; x1; y0; y1; vbsigns'];
        
        % Plot the progress, if so desired
        
        if (showprog == 1)
            patch([x0, x1, x1, x0],[y0,y0,y1,y1], ...
                  sum(vbsigns)*0.25,'EdgeColor','none');
            caxis([-1,1])
            %axis equal;
            axis off;
            hold on;
            drawnow;
        end;
        
    else
        
        % The box did not validate, now subdivide
        
        if randn(1,1) > 0.0
            sigmac = sigma(1);
        else
            sigmac = sigma(2);
        end;
        
        if (x1 - x0) > (y1 - y0)
            xm = x0 + sigmac * (x1 - x0);
            
            xa0 = x0;   xa1 = xm;   xb0 = xm;   xb1 = x1;
            ya0 = y0;   ya1 = y1;   yb0 = y0;   yb1 = y1;
            
            minboxsize = min([xm-x0, x1-xm, y1-y0]);
        else
            ym = y0 + sigmac * (y1 - y0);
            
            xa0 = x0;   xa1 = x1;   xb0 = x0;   xb1 = x1;
            ya0 = y0;   ya1 = ym;   yb0 = ym;   yb1 = y1;
            
            minboxsize = min([ym-y0, y1-ym, x1-x0]);
        end;
        
        % Exit if one of the boxes is too small
        
        if (minboxsize < rhomin)
            disp('minboxsize reached');
            vflag  = 0;
            vboxes = [];
            return;
        end;
            
        % Add the new boxes to the list Q
        
        Qlen = Qlen + 1;
        Qdata(:,Qlen) = [xa0; xa1; ya0; ya1];
        Qlen = Qlen + 1;
        Qdata(:,Qlen) = [xb0; xb1; yb0; yb1];
    end;
end;

vflag  = 1;
vboxes = Vdata(:,1:Vlen);

end

