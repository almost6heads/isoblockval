function answer = validateposinf(eval_v,x,y,pnfac)
%
%   function answer = validateposinf(eval_v,x,y,pnfac)
%
% This function tests whether the function specified in eval_v
% is positive over the box x times y. Tests for negativity can be
% performed if the parameter pnfac is negative.
%
% Input arguments:
%
%    eval_v         Function handle for the function v.
%    x              Intval interval with the x-coordinates of the box
%    y              Intval interval with the y-coordinates of the box
%    pnfac          Prefactor used for the function evaluations:
%                   pnfac =  1: Test for positivity of v
%                   pnfac = -1: Test for negativity of v
%
% Output argument:
%
%   answer     1 = success, 0 = could not verify positivity/negativity
%

% Define the performance parameters

rho_mach = 1.0e-14;
f_rho    = 0.1;
M_depth  = 12;

% Predefine the lists which a given maximal length

%Lmax   = 10000;
%Llow   = zeros(1,Lmax);
%Ldepth = zeros(1,Lmax);
%Lxrect = zeros(1,Lmax);
%Lyrect = zeros(1,Lmax);
Llen   = 0;

% Step (P1) of the algorithm

p0x = intval(mid(x));   p0y = intval(mid(y));
p1x = intval(inf(x));   p1y = intval(inf(y));
p2x = intval(sup(x));   p2y = intval(inf(y));
p3x = intval(sup(x));   p3y = intval(sup(y));
p4x = intval(inf(x));   p4y = intval(sup(y));

vp0 = pnfac * eval_v(p0x,p0y);
vp1 = pnfac * eval_v(p1x,p1y);
vp2 = pnfac * eval_v(p2x,p2y);
vp3 = pnfac * eval_v(p3x,p3y);
vp4 = pnfac * eval_v(p4x,p4y);

Mv = min([sup(vp0),sup(vp1),sup(vp2),sup(vp3),sup(vp4)]);
vr = pnfac * eval_v(x,y);

% Step (P2) of the algorithm

if (Mv <= 0.0)
    answer = false;
    return;
end;

% Step (P3) of the algorithm

if (inf(vr) > 0.0)
    answer = true;
    return;
end;

% Step (P4) of the algorithm

Llen = 1;
Llow(1,Llen)   = inf(vr);
Ldepth(1,Llen) = 1;
Lxrect(1,Llen) = x;
Lyrect(1,Llen) = y;

rho = max([f_rho * Mv, rho_mach]);

% Step (P5) of the algorithm

while (Llen > 0)
    
    % Step (P5a) of the algorithm
    
    Wlow   = Llow(1,Llen);
    Wdepth = Ldepth(1,Llen);
    Wxrect = Lxrect(1,Llen);
    Wyrect = Lyrect(1,Llen);
    Llen   = Llen - 1;
    
    % Step (P5b) of the algorithm
    
    if (Wdepth > M_depth)
        answer = false;
        return;
    end;
    
    % Step (P5c) of the algorithm
    
    if rad(Wxrect) > rad(Wyrect)
        W1xrect = infsup(inf(Wxrect),mid(Wxrect));
        W2xrect = infsup(mid(Wxrect),sup(Wxrect));
        W1yrect = Wyrect;
        W2yrect = Wyrect;
    else
        W1xrect = Wxrect;
        W2xrect = Wxrect;
        W1yrect = infsup(inf(Wyrect),mid(Wyrect));
        W2yrect = infsup(mid(Wyrect),sup(Wyrect));
    end;
    
    vW1rect = pnfac * eval_v(W1xrect,W1yrect);
    vW2rect = pnfac * eval_v(W2xrect,W2yrect);
    
    % Step (P5d) of the algorithm
    
    vW1mid = pnfac * eval_v(intval(mid(W1xrect)),intval(mid(W1yrect)));
    vW2mid = pnfac * eval_v(intval(mid(W2xrect)),intval(mid(W2yrect)));
    
    if (sup(vW1mid) <= 0.0)
        answer = false;
        return;
    end;
    
    if (sup(vW2mid) <= 0.0)
        answer = false;
        return;
    end;
    
    % Step (P5e) of the algorithm
    
    Lchanged = false;
    
    if ((inf(vW1rect) <= 0.0) && (rad(vW1rect) <= rho))
        answer = false;
        return;
    end;
    
    if ((inf(vW2rect) <= 0.0) && (rad(vW2rect) <= rho))
        answer = false;
        return;
    end;
    
    if ((inf(vW1rect) <= 0.0) && (rad(vW1rect) > rho))
        Llen           = Llen + 1;
        Lchanged       = true;
        Llow(1,Llen)   = inf(vW1rect);
        Ldepth(1,Llen) = Wdepth + 1;
        Lxrect(1,Llen) = W1xrect;
        Lyrect(1,Llen) = W1yrect;
    end;
    
    if ((inf(vW2rect) <= 0.0) && (rad(vW2rect) > rho))
        Llen           = Llen + 1;
        Lchanged       = true;
        Llow(1,Llen)   = inf(vW2rect);
        Ldepth(1,Llen) = Wdepth + 1;
        Lxrect(1,Llen) = W2xrect;
        Lyrect(1,Llen) = W2yrect;
    end;
    
    [Ldummy,Lsort]   = sort(Llow(1,1:Llen),2,'descend');
    Llow(1,1:Llen)   = Llow(1,Lsort);
    Ldepth(1,1:Llen) = Ldepth(1,Lsort);
    Lxrect(1,1:Llen) = Lxrect(1,Lsort);
    Lyrect(1,1:Llen) = Lyrect(1,Lsort);
    
end;

answer = true;

end

