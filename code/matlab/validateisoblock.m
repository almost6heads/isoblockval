function [vflag,vboxes] = validateisoblock(fct_e,fct_t,x,y,varargin)
%
%   function [vflag,vboxes] = validateisoblock(fct_e, fct_t, x, y ...
%                           [,showprog,MaxNsweeps,subdivfrac])
%
% This function tries to rigorously validate an isolating block.
% The tangency test function is given by fct_e and defined over a
% box x times y. The tangency test function is specified in fct_t.
%
% Input arguments:
%
%    fct_e            Function handle for the exit set test function.
%                     The code also needs files fct_ex.m and fct_ey.m
%                     which contain the corresponding partial derivatives.
%    fct_t            Function handle for the tangency test function.
%                     Here only the function is necessary, no derivatives.
%    x                Intval interval with the x-coordinates of the box
%    y                Intval interval with the y-coordinates of the box
%    [showprog]       1 = plot boxes as they are validated
%    [MaxNsweeps]     Maximal number of subdivision sweeps which are
%                     performed if fct_t is not positive on a box B
%                     which contains part of the nodal line.
%    [subdivfrac]     If fct_t is not positive on a box B which contains
%                     part of the nodal line, the box has to be subdivided.
%                     This parameter specifies which fraction of the 
%                     side lengths of B is an upper bound on the side
%                     lengths for the new subboxes.
%
% The arguments in brackets are optional. If any one of these is given,
% the ones preceding it have to be specified as well. If they are not
% specified their default values are showprog = 0, MaxNsweeps = 10,
% and subdivfrac = 0.5.
%
% Output arguments:
%
%   vflag      1 = success, 0 = could not verify the isolating block
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

minargs = 4;

if (nargin == minargs)
    showprog   = 0;
    MaxNsweeps = 10;
    subdivfrac = 0.5;
elseif (nargin == minargs+1)
    showprog   = varargin{1,1};
    MaxNsweeps = 10;
    subdivfrac = 0.5;
elseif (nargin == minargs+2)
    showprog   = varargin{1,1};
    MaxNsweeps = varargin{1,2};
    subdivfrac = 0.5;
elseif (nargin == minargs+3)
    showprog   = varargin{1,1};
    MaxNsweeps = varargin{1,2};
    subdivfrac = varargin{1,3};
end;

% Validate the exit set

[evflag,evboxes] = validatenodalset(fct_e,x,y,showprog);

if (evflag == 1)
    [Nd,Nevboxes] = size(evboxes);
    fprintf('\n');
    fprintf('Exit set validated with %d boxes.\n\n',Nevboxes);
else
    disp('Exit set did not validate!')
    vflag  = 0;
    vboxes = [];
    return;
end;

if (showprog == 1)
    drawnow;
    print('-djpeg100','scriptIsoBlock1.jpg');
end;

% Initialize graphics if progress should be shown

if (showprog == 1)
    figure;
    plot([inf(x), sup(x), sup(x), inf(x), inf(x)], ...
         [inf(y), inf(y), sup(y), sup(y), inf(y)], 'k');
    axis([inf(x),sup(x),inf(y),sup(y)]);
    axis off;
    hold on;
    drawnow;
end;

% Initialize array for the boxes which successfully were validated
% using the tangency test function, or were not containing the
% nodal line

doneboxes  = zeros(8,Nevboxes);
Ndoneboxes = 0;

% Sweep through the boxes, possibly several times until validated

Nsweep = 0;

while ((Nevboxes > 0) && (Nsweep < MaxNsweeps))
    
    % Initialize stats

    Nsweep = Nsweep + 1;
    Nall   = Nevboxes;
    Npn    = 0;
    Nfail  = 0;
    Ntpos  = 0;
    
    % Initialize array for the boxes which have to be subdivided

    todoboxes  = zeros(8,2);
    Ntodoboxes = 0;
    
    % Loop through all boxes in evboxes and validate the test
    % function positivity if necessary
    
    for k=1:Nevboxes
        
        % Get the k-th box
        
        x0 = evboxes(1,k);   x1 = evboxes(2,k);
        y0 = evboxes(3,k);   y1 = evboxes(4,k);
        
        s0 = sum(evboxes(5:8,k));
        
        % If necessary, validate the tangency test function
        
        if (abs(s0) < 4)
            xc = infsup(x0,x1);
            yc = infsup(y0,y1);
            answer = validateposinf(fct_t,xc,yc,1);
        else
            answer = true;
        end;
        
        % Act depending on whether it validated or not
        
        if (answer)
            
            % The tangency test function is positive, or the
            % box was strictly positive or negative
            
            if (abs(s0) < 4)
                Ntpos = Ntpos + 1;
            else
                Npn = Npn + 1;
            end;
            
            % Plot the progress, if so desired
            
            if (showprog == 1)
                patch([x0, x1, x1, x0],[y0,y0,y1,y1], ...
                      s0*0.25,'EdgeColor','none');
                caxis([-1,1])
                %axis equal;
                axis off;
                hold on;
                drawnow;
            end;
            
            % Add the box to doneboxes
            
            Ndoneboxes = Ndoneboxes + 1;
            doneboxes(1:8,Ndoneboxes) = evboxes(1:8,k);
            
        else
            
            % The positivity test failed
            
            Nfail = Nfail + 1;
            
            % Subdivide the failed box
            
            [cevflag,cevboxes] = validatenodalset(fct_e,xc,yc, ...
                0,subdivfrac*(x1-x0),subdivfrac*(y1-y0));
            
            % If subdivision failed, exit
            
            if (cevflag == 0)
                disp('Exit set did not validate!');
                vflag  = 0;
                vboxes = [];
                return;
            end;
            
            % If subdivision succeeded, add the new boxes to the todo list
            
            [Nd,Ncevboxes] = size(cevboxes);
            
            Ntd0 = Ntodoboxes + 1;
            Ntd1 = Ntodoboxes + Ncevboxes;
            
            todoboxes(1:8,Ntd0:Ntd1) = cevboxes(1:8,:);
            Ntodoboxes = Ntodoboxes + Ncevboxes;
        end;
    end;
    
    % We have worked through all the boxes, display the stats
    
    fprintf('Sweep %2d:\n',Nsweep);
    fprintf('---------------------\n');
    fprintf('pos/neg boxes = %5d\n',Npn);
    fprintf('valid t boxes = %5d\n',Ntpos);
    fprintf('invalid boxes = %5d\n',Nfail);
    fprintf('  total boxes = %5d\n',Nall);
    fprintf('  -------------------\n');
    fprintf('    new boxes = %5d\n',Ntodoboxes);
    fprintf('---------------------\n');
    
    % Create new evboxes array
    
    Nevboxes = Ntodoboxes;
    evboxes  = todoboxes(1:8,1:Ntodoboxes);
    
    drawnow;
    %print('-depsc2',sprintf('validated_ex1b_sweep%1d.eps',Nsweep));
    
end;

% Return the box data

if (Nevboxes == 0)
    vflag  = true;
    vboxes = doneboxes;
else
    vflag  = false;
    vboxes = doneboxes;
end;

end

