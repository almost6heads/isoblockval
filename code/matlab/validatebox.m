function [validtype,signs] = validatebox(fct_u,fct_ux,fct_uy,x,y)
%
%
%

% Validate the corners of the box

p1x = intval(inf(x));   p1y = intval(inf(y));   u1 = fct_u(p1x,p1y);
p2x = intval(sup(x));   p2y = intval(inf(y));   u2 = fct_u(p2x,p2y);
p3x = intval(sup(x));   p3y = intval(sup(y));   u3 = fct_u(p3x,p3y);
p4x = intval(inf(x));   p4y = intval(sup(y));   u4 = fct_u(p4x,p4y);

s1 = 0; s2 = 0; s3 = 0; s4 = 0;

if (inf(u1) > 0.0), s1 = 1; elseif (sup(u1) < 0.0), s1 = -1; end;
if (inf(u2) > 0.0), s2 = 1; elseif (sup(u2) < 0.0), s2 = -1; end;
if (inf(u3) > 0.0), s3 = 1; elseif (sup(u3) < 0.0), s3 = -1; end;
if (inf(u4) > 0.0), s4 = 1; elseif (sup(u4) < 0.0), s4 = -1; end;

stype = s1+s2+s3+s4;
signs = [s1,s2,s3,s4];

if (s1*s2*s3*s4 == 0)
    validtype = -1;
    return;
end;

if ((stype == 0) && (s1*s2 < 0) && (s2*s3 < 0))
    validtype = 0;
    return;
end;

% Validate the edges according to the signs

x12 = x;
y12 = intval(inf(y));

if (s1*s2 > 0)
    testflag = validateposinf(fct_u,x12,y12,s2);
else
    testflag = validateposinf(fct_ux,x12,y12,s2);
end;

if (testflag == false)
    validtype = 0;
    return;
end;

x23 = intval(sup(x));
y23 = y;

if (s2*s3 > 0)
    testflag = validateposinf(fct_u,x23,y23,s3);
else
    testflag = validateposinf(fct_uy,x23,y23,s3);
end;

if (testflag == false)
    validtype = 0;
    return;
end;

x34 = x;
y34 = intval(sup(y));

if (s3*s4 > 0)
    testflag = validateposinf(fct_u,x34,y34,s3);
else
    testflag = validateposinf(fct_ux,x34,y34,s3);
end;

if (testflag == false)
    validtype = 0;
    return;
end;

x41 = intval(inf(x));
y41 = y;

if (s4*s1 > 0)
    testflag = validateposinf(fct_u,x41,y41,s4);
else
    testflag = validateposinf(fct_uy,x41,y41,s4);
end;

if (testflag == false)
    validtype = 0;
    return;
end;

% Now validate the rectangle itself, if you actually get here

validtype = 0;

switch abs(stype)
    case 4
        if validateposinf(fct_u,x,y,s1)
            validtype = 1;
        end;
    case 2
        if ((s1*s2 < 0) && (s1*s4 < 0))
            if validateposinf(fct_ux,x,y,s2)
                validtype = 1;
            elseif validateposinf(fct_uy,x,y,s3)
                validtype = 1;
            end;
        end;
        if ((s2*s3 < 0) && (s2*s1 < 0))
            if validateposinf(fct_ux,x,y,s2)
                validtype = 1;
            elseif validateposinf(fct_uy,x,y,s3)
                validtype = 1;
            end;
        end;
        if ((s3*s4 < 0) && (s3*s2 < 0))
            if validateposinf(fct_ux,x,y,s3)
                validtype = 1;
            elseif validateposinf(fct_uy,x,y,s3)
                validtype = 1;
            end;
        end;
        if ((s4*s1 < 0) && (s4*s3 < 0))
            if validateposinf(fct_ux,x,y,s3)
                validtype = 1;
            elseif validateposinf(fct_uy,x,y,s4)
                validtype = 1;
            end;
        end;
    case 0
        if (s1*s2 > 0)
            if validateposinf(fct_uy,x,y,s3)
                validtype = 1;
            end;
        else
            if validateposinf(fct_ux,x,y,s2)
                validtype = 1;
            end;
        end;
end;

end

