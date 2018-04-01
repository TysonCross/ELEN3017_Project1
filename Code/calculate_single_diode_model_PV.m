% Simplified mathematical model
% From http://www.mdpi.com/1996-1073/9/5/326/pdf
clc; clear all; warning off; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'));

view    = [1 2 3 4 5]; % [1 2 3 4 5]
output  = [1 2 3 4 5];

%% Data input
% 21 Dec/ 21 June / 21 March
T_a = 18.8;                                                 % [C]       <- Will vary
G = [400 600 800 1000 1200];                                % [W/m^2]   <- Will vary
G_pu = G./max(max(G),1000);                                	% Normalised (Site data>1000)

% From datasheet for TSM-300 PA14 at STC
P_max = 300;                                                % [W]
V_mp_0 = 36.9;                                              % [V]
I_mp_0 = 8.13;                                              % [A]
V_oc_0 = 45.3;                                              % [V]
I_sc_0 = 8.60;                                              % [A]
efficiency = 15.5;

% Temperature coefficients
alpha_P_sc = -0.44;                                         % percentage/°C
alpha_I_sc = -0.33                                          % percentage/°C, short-circuit current
alpha_V_oc = 0.046                                          % percentage/°C, open-circuit voltage

% Operating Temperature of a cell
% (relates disparity between NOTC and STC)
NOCT = 45;                                                  % [C]
T_c = T_a + G./800.*(NOCT-20);
delta_T = T_c-25;

% For a single module made of multiple cells, connected in series
N_s = 72;                                                   % <- must check
N_p = 1;                                                    % <- must check
% V_cell = V_module/N_s;                                    % implies V_module = V_cell*N_s;
% I_cell = I_module/N_p;                                    % implies I_module = I_cell*N_p;

alpha_I = alpha_I_sc.*delta_T;
alpha_V = alpha_V_oc.*delta_T

%% Calculations
I_ph = G_pu.*(I_sc_0 + alpha_I);
I_mpp = G_pu.*(I_mp_0 + alpha_I);
V_oc = V_oc_0 - alpha_V;
V_mpp = V_mp_0 - alpha_V;

R_s = ((V_oc_0 - V_mp_0)/4) ./ (G_pu.*(I_mp_0 + alpha_I_sc));
R_sh = Inf;

beta = G_pu.*(I_sc_0 + alpha_I);
gamma = 1/(V_mp_0 - V_oc_0) .* log((I_sc_0 - I_mp_0)./(I_sc_0 + alpha_I));
p = 1;

V = [0:V_oc_0];
for i=1:numel(V)
    I(:,i) = G_pu.*(I_sc_0 + alpha_I) - beta.*exp(gamma.*(V(i) + alpha_V - V_oc_0));
    P(:,i) = V(i).*I(:,i).*I(:,i);
end
    
disp('Calculations complete')

% plot
fig1 = figure;
plot(V,P)                                                   % plot power vs voltage
hold on

fig2 = figure;
plot(V,I)                                                   % plot current vs voltage
hold on

