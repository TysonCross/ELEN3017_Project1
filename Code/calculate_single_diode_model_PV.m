% From datasheet for TSM-300 PA14
V_oc = 41.3; % [V]
I_sc = 7.04; % [A]
I_mp = 6.55; % [A]
V_mp = 33.3; % [V]
efficiency = 15.5;

factor = (2*V_mp-V_oc)/...
    (I_mp + (I_sc-I_mp)*log(1-(I_mp/I_sc)));

V_t = (I_sc-I_mp)*factor
R_s = (V_mp/I_mp)-factor



