function [kbar,cbar,zbar,ybar] = fun_ss(par)
zbar = 1;
kbar = (par.alpha * zbar / (1 / par.beta - 1 + par.delta))^(1 / (1 - par.alpha));
ybar = zbar * kbar^par.alpha;
cbar = ybar - par.delta * kbar;
end %end function
