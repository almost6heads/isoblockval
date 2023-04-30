function z=eval_c1u(x,y)
phi=x;
theta=y;
z=10.*cos(theta).^2+(-1/50).*sin(theta).^2.*(10.*cos(phi).^2+10.*sin(phi) ...
  .^2+9.*cos(phi).^4.*sin(theta).^2);
