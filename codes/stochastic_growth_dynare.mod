% Dynare example based on stochastic growth model, Cardiff guest lecture

% (1) declare endogenous variables

var      c, k, z;                                                    

% (2) declare exogenous variables (shocks)

varexo   e;                               

% (3) declare parameters

parameters alpha, beta, delta, sigma, rho, sigmaeps;  

alpha    = 0.35;  // capital share
beta     = 0.95;  // discount factor
delta    = 0.1;   // depreciation rate
rho      = 0.95;  // TFP persistence
sigma    = 3.00;  // CRRA
sigmaeps = 0.01;  // TFP standard deviation

% (4) declare the model equations. We want approximation in logs

model;                                   

% resource constraint
exp(c) + exp(k) = exp(z)*(exp(k(-1))^alpha)+(1-delta)*exp(k(-1));
                  
% consumption Euler equation
exp(c)^(-sigma) = beta*(exp(c(+1))^(-sigma))*(alpha*exp(z(+1))*(exp(k)^(alpha-1))+1-delta);

% law of motion productivity (already in logs, so no need to transform it)
z = rho*z(-1) + e;


end;


% (5) solve the steady state 
initval;
c = 0.75;
k = 3;
z = 1;
e = 0;
end;

steady;

% specify variance of shocks

shocks;
var e = 100*sigmaeps^2;
end;

% (6) solve the dynamics
%stoch_simul(order=1,irf=40);
stoch_simul(order=1,noprint,irf=40);
//stoch_simul(order=1,irf=40) c k;
//stoch_simul(order=1,nograph,irf=40);