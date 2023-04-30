function z=eval_c1uy(x,y)
phi=x;
theta=y;
z=(-2/25).*cos(theta).*sin(theta).*(5.*cos(phi).^2+5.*(50+sin(phi).^2)+9.* ...
  cos(phi).^4.*sin(theta).^2);
