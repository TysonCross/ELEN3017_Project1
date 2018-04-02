%% Calculations
I_ph = G_pu.*(I_sc_0 + alpha_I);
I_mpp = abs(G_pu.*(I_mp_0 + alpha_I));
V_oc = V_oc_0 - alpha_V;
V_mpp = V_mp_0 - alpha_V;

R_s = ((V_oc_0 - V_mp_0)/4) ./ (G_pu.*(I_mp_0 + alpha_I_sc));
R_sh = Inf;

beta = G_pu.*(I_sc_0 + alpha_I);
gamma = 1/(V_mp_0 - V_oc_0) .* log((I_sc_0 - I_mp_0)./(I_sc_0 + alpha_I));
p = 1;

V = [0:0.5:50];
for i=1:numel(V)
    I(:,i) = G_pu.*(I_sc_0 + alpha_I) - beta.*exp(gamma.*(V(i) + alpha_V - V_oc_0));
    P(:,i) = V(i).*I(:,i);
	R(:,i) = V(i)./I(:,i);
end

[n m]  = size(P);
mpp_index =[];
for i=1:n
    [MPP(i) mpp_index(i)] = max(P(i,:));
    Load(i) = R(i,mpp_index(i));
end
