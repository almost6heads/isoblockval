function z=eval_c1w(x,y)
phi=x;
theta=y;
z=(1/1250).*(125000.*cos(theta).^2+sin(theta).^2.*(50.*cos(phi).^2+50.* ...
  sin(phi).^2+135.*cos(phi).^4.*sin(theta).^2+(-900).*cos(phi).^3.*sin( ...
  phi).*sin(theta).^2+81.*cos(phi).^6.*sin(theta).^4));
