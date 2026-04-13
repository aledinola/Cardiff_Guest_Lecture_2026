//****************************************************************************
//Define variables
//****************************************************************************

var y           ${y}$ (long_name='output')
    c           ${c}$ (long_name='consumption')
    k           ${k}$ (long_name='capital')
    z           ${z}$ (long_name='TFP')
    log_y       ${\log(y)}$ (long_name='log output')
    log_k       ${\log(k)}$ (long_name='log capital stock')
    log_c       ${\log(c)}$ (long_name='log consumption')
    ;

varexo eps_z ${\varepsilon_z}$ (long_name='TFP shock')
    ;
    
parameters 
    beta       ${\beta}$   (long_name='discount factor')
    sigma      ${\sigma}$  (long_name='risk aversion')
    delta      ${\delta}$  (long_name='depreciation rate')
    alpha      ${\alpha}$  (long_name='capital share')
    rhoz       ${\rho_z}$  (long_name='persistence TFP shock')
    sigz       ${\sigma_z}$ (long_name='standard deviation TFP')
    ;

//****************************************************************************
//Set parameter values
//****************************************************************************

load paramfile
set_param_value('beta',beta)
set_param_value('sigma',sigma)
set_param_value('delta',delta)
set_param_value('alpha',alpha)
set_param_value('rhoz',rhoz)
set_param_value('sigz',sigz)

//****************************************************************************
//enter the model equations (model-block)
//****************************************************************************

model;
[name='Euler equation']
c^(-sigma)=beta*c(+1)^(-sigma)*(alpha*exp(z(+1))*(k)^(alpha-1)+1-delta);
[name='resource constraint']
c+k = exp(z)*k(-1)^alpha+(1-delta)*k(-1);
[name='production function']
y   = exp(z)*k(-1)^alpha;
[name='exogenous TFP process']
z=rhoz*z(-1)+eps_z;
[name='Definition log output']
log_y = log(y);
[name='Definition log capital']
log_k = log(k);
[name='Definition log consumption']
log_c = log(c);
end;

//****************************************************************************
// Provide steady state values 
//****************************************************************************

steady_state_model;
    k     = (alpha/(1/beta-1+delta))^(1/(1-alpha)); 
    y     = k^alpha;
    c     = k^(alpha)-delta*k;
    log_y = log(y);
    log_k = log(k);
    log_c = log(c);
    z     = 0; 
end;

//****************************************************************************
//set shock variances
//****************************************************************************

shocks;
    var eps_z = sigz^2;
end;

//****************************************************************************
//check the starting values for the steady state
//****************************************************************************

resid;

//****************************************************************************
// compute steady state given the starting values
//****************************************************************************

steady;
//****************************************************************************
// check Blanchard-Kahn-conditions
//****************************************************************************

check;

//****************************************************************************
// compute policy function at first order, do IRFs and compute moments with HP-filter
//****************************************************************************

stoch_simul(order=1,irf=@{T_irf},hp_filter=1600) z log_y log_k log_c;