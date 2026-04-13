function [] = fun_plot_quadratic(coef,roots_eta_kk,fig_dir)
%Plot second order polynomial in eta_kk as a function of eta_kk

eta_kk_vec = linspace(0.9,1.2,300)';
eta_polynomial = coef(1)*eta_kk_vec.^2 + coef(2)*eta_kk_vec + coef(3);

% Find stable and unstable root:
idx_stable      = abs(roots_eta_kk) < 1;
eta_kk_stable   = roots_eta_kk(idx_stable);
eta_kk_unstable = roots_eta_kk(~idx_stable);

fig = figure('Color','w');
plot(eta_kk_vec,eta_polynomial,'LineWidth',2.0);
yline(0,'LineWidth',2.0)
hold on
plot(eta_kk_stable,0,'-bo','LineWidth',4.0)
hold on
plot(eta_kk_unstable,0,'-ro','LineWidth',4.0)
title('Quadratic equation P(\eta_{kk})=0','FontSize',16);
xlabel('\eta_{kk}','FontSize',16);
grid on;

exportgraphics(fig,fullfile(fig_dir,'quadratic.png'),'Resolution',300);

end %end function