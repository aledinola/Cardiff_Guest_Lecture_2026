%% Cardiff guest lecture
%% Alessandro Di Nola
%% Solve stochastic growth model using method of undetermined coefficients
% Reference: slides\notes.tex
% This script requires the auxiliary functions 
% fun_ss.m and fun_plot_quadratic.m
clear; clc; close all;

fig_dir = fullfile('..','slides','figs');
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end

%% Set parameter values
par.beta  = 0.95;     % Discount factor
par.sigma = 3.00;     % CRRA in utility consumption
par.alpha = 0.35;     % Capital coeff in production fucntion
par.delta = 0.1;      % Depreciation rate
par.rho   = 0.95;     % Autocorrelation TFP z shock
par.sigma_eps = 0.01; % Stand deviation of innovation to z

%% Compute deterministic steady state
[kbar,cbar,zbar,ybar] = fun_ss(par);

fprintf('\nDeterministic steady state\n');
fprintf('kbar = %8.4f\n',kbar);
fprintf('cbar = %8.4f\n',cbar);
fprintf('zbar = %8.4f\n',zbar);
fprintf('ybar = %8.4f\n',ybar);

%% Set coefficients of the linear system
% They are denoted as alpha1-4 and beta1-4 in notes.tex
alpha1 = cbar / kbar;
alpha2 = 1;
alpha3 = -1 / par.beta;
alpha4 = -(1 / par.alpha) * (1 / par.beta - 1 + par.delta);

beta1 = 1;
beta2 = -1;
beta3 = (1 / par.sigma) * (1 - par.beta * (1 - par.delta)) * par.rho;
beta4 = -(1 / par.sigma) * (1 - par.alpha) * (1 - par.beta * (1 - par.delta));

%% Guess linear policy functions for c(t) and k(t+1) as functions of
% the state variables k(t) and z(t)
% c_hat(t)   = eta_ck*k_hat(t) + eta_cz*z_hat(t)
% k_hat(t+1) = eta_kk*k_hat(t) + eta_kz*z_hat(t)

% Find eta_ck, eta_cz, eta_kk, eta_kz.
% The formulas follow slides\notes.tex.

% The quadratic equation for eta_kk is
% A*eta_kk^2 + B*eta_kk + C = 0.
% Matlab's roots function expects the coefficients in the vector [A B C].
coef_quad = zeros(1,3);
coef_quad(1) = beta2 * alpha2;
coef_quad(2) = beta1 * alpha2 + beta2 * alpha3 - beta4 * alpha1;
coef_quad(3) = beta1 * alpha3;

% Solve the quadratic equation
roots_eta_kk = roots(coef_quad);

% Plot the quadratic equation (a second-order polynomial) wrt eta_kk:
fun_plot_quadratic(coef_quad,roots_eta_kk,fig_dir);

% The economic solution is the stable root, the one inside the unit circle.
idx_stable = abs(roots_eta_kk) < 1;
eta_kk = roots_eta_kk(idx_stable);
eta_kk = eta_kk(1);

eta_ck = -(alpha2 * eta_kk + alpha3) / alpha1;

eta_kz = ((beta1 + par.rho * beta2) * alpha4 - alpha1 * beta3) / ...
         (alpha1 * beta4 - beta1 * alpha2 + ...
          beta2 * (alpha1 * eta_ck - alpha2 * par.rho));

eta_cz = -(alpha2 * eta_kz + alpha4) / alpha1;

fprintf('\nPolicy coefficients\n');
fprintf('eta_ck = %8.4f\n',eta_ck);
fprintf('eta_cz = %8.4f\n',eta_cz);
fprintf('eta_kk = %8.4f\n',eta_kk);
fprintf('eta_kz = %8.4f\n',eta_kz);

%% Impulse response to a positive productivity shock
T = 40;
eps_irf = zeros(T,1);
eps_irf(1) = par.sigma_eps;

zhat_irf = zeros(T,1);
khat_irf = zeros(T+1,1);
chat_irf = zeros(T,1);
yhat_irf = zeros(T,1);

for t = 1:T
    if t == 1
        % zhat_irf(0) is implicitely set to zero
        zhat_irf(t) = eps_irf(t);
    else
        zhat_irf(t) = par.rho * zhat_irf(t-1) + eps_irf(t);
    end

    chat_irf(t)   = eta_ck * khat_irf(t) + eta_cz * zhat_irf(t);
    khat_irf(t+1) = eta_kk * khat_irf(t) + eta_kz * zhat_irf(t);
    yhat_irf(t)   = zhat_irf(t) + par.alpha * khat_irf(t);
end

fig_irf = figure('Color','w');
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

nexttile;
plot(0:T-1,zhat_irf,'LineWidth',1.5);
title('Productivity');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(0:T-1,chat_irf,'LineWidth',1.5);
title('Consumption');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(0:T-1,khat_irf(1:T),'LineWidth',1.5);
title('Capital');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(0:T-1,yhat_irf,'LineWidth',1.5);
title('Output');
xlabel('Periods');
ylabel('Percent');
grid on;

exportgraphics(fig_irf,fullfile(fig_dir,'undet_coeffs_irf.png'),'Resolution',300);

%% Stochastic simulation
rng(1234);
Tsim = 200;
eps_sim = par.sigma_eps * randn(Tsim,1);

zhat_sim = zeros(Tsim,1);
khat_sim = zeros(Tsim+1,1);
chat_sim = zeros(Tsim,1);
yhat_sim = zeros(Tsim,1);

for t = 1:Tsim
    if t == 1
        zhat_sim(t) = eps_sim(t);
    else
        zhat_sim(t) = par.rho * zhat_sim(t-1) + eps_sim(t);
    end

    chat_sim(t)   = eta_ck * khat_sim(t) + eta_cz * zhat_sim(t);
    khat_sim(t+1) = eta_kk * khat_sim(t) + eta_kz * zhat_sim(t);
    yhat_sim(t)   = zhat_sim(t) + par.alpha * khat_sim(t);
end

fig_sim = figure('Color','w');
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

nexttile;
plot(1:Tsim,zhat_sim,'LineWidth',1.0);
title('Productivity');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(1:Tsim,chat_sim,'LineWidth',1.0);
title('Consumption');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(1:Tsim, khat_sim(1:Tsim),'LineWidth',1.0);
title('Capital');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(1:Tsim, yhat_sim,'LineWidth',1.0);
title('Output');
xlabel('Periods');
ylabel('Percent');
grid on;

exportgraphics(fig_sim,fullfile(fig_dir,'undet_coeffs_simulation.png'),'Resolution',300);
