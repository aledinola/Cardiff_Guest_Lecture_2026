%% Cardiff guest lecture
%% Alessandro Di Nola
%% Solve stochastic growth model using DYNARE, with some TRICKS

clear,clc,close all

%% Set parameter values
beta  = 0.95;     % Discount factor
sigma = 3.00;     % CRRA in utility consumption
alpha = 0.35;     % Capital coeff in production fucntion
delta = 0.1;      % Depreciation rate
rhoz  = 0.95;     % Autocorrelation TFP z shock
sigz  = 0.01;     % Stand deviation of innovation to z
T_irf = 40;       % Number of periods in IRF

%% Save parameters to mat file
save paramfile beta sigma alpha delta rhoz sigz

eval(sprintf('dynare stochastic_growth_dynare2 noclearall -DT_irf=%d', T_irf));

%% Plot irfs using Dynare outputs

c_hat_irf = oo_.irfs.log_c_eps_z;
k_hat_irf = oo_.irfs.log_k_eps_z;
y_hat_irf = oo_.irfs.log_y_eps_z;
z_hat_irf = oo_.irfs.z_eps_z;

T = numel(oo_.irfs.log_c_eps_z);

tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

nexttile;
plot(0:T-1,z_hat_irf,'LineWidth',1.5);
title('Productivity');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(0:T-1,c_hat_irf,'LineWidth',1.5);
title('Consumption');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(0:T-1,k_hat_irf(1:T),'LineWidth',1.5);
title('Capital');
xlabel('Periods');
ylabel('Percent');
grid on;

nexttile;
plot(0:T-1,y_hat_irf,'LineWidth',1.5);
title('Output');
xlabel('Periods');
ylabel('Percent');
grid on;

%% Loop over parameters

rhoz_vec = [0.95,0.99];
n_rho = numel(rhoz_vec);
legend_labels = compose('\\rho_z = %.2f', rhoz_vec);


c_hat_irf = zeros(T_irf,n_rho);
k_hat_irf = zeros(T_irf,n_rho);
y_hat_irf = zeros(T_irf,n_rho);
z_hat_irf = zeros(T_irf,n_rho);

for ii=1:n_rho
    rhoz = rhoz_vec(ii);
    save paramfile beta sigma alpha delta rhoz sigz
    eval(sprintf('dynare stochastic_growth_dynare2 noclearall -DT_irf=%d', T_irf));

    c_hat_irf(:,ii) = oo_.irfs.log_c_eps_z;
    k_hat_irf(:,ii) = oo_.irfs.log_k_eps_z;
    y_hat_irf(:,ii) = oo_.irfs.log_y_eps_z;
    z_hat_irf(:,ii) = oo_.irfs.z_eps_z;

end

tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

nexttile;
plot(0:T-1,z_hat_irf(:,1),'LineWidth',1.5);
hold on
plot(0:T-1,z_hat_irf(:,2),'LineWidth',1.5);
title('Productivity');
xlabel('Periods');
ylabel('Percent');
legend(legend_labels,'Location','best');
grid on;

nexttile;
plot(0:T-1,c_hat_irf(:,1),'LineWidth',1.5);
hold on
plot(0:T-1,c_hat_irf(:,2),'LineWidth',1.5);
title('Consumption');
xlabel('Periods');
ylabel('Percent');
legend(legend_labels,'Location','best');
grid on;

nexttile;
plot(0:T-1,k_hat_irf(1:T,1),'LineWidth',1.5);
hold on
plot(0:T-1,k_hat_irf(1:T,2),'LineWidth',1.5);
title('Capital');
xlabel('Periods');
ylabel('Percent');
legend(legend_labels,'Location','best');
grid on;

nexttile;
plot(0:T-1,y_hat_irf(:,1),'LineWidth',1.5);
hold on
plot(0:T-1,y_hat_irf(:,2),'LineWidth',1.5);
title('Output');
xlabel('Periods');
ylabel('Percent');
legend(legend_labels,'Location','best');
grid on;
