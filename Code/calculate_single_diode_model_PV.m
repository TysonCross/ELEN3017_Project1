% Simplified mathematical model
% From http://www.mdpi.com/1996-1073/9/5/326/pdf
clc; clear all; warning off; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'));

view    = [1 2]; % [1 2]
output  = [];

%% Data input
% 21 Dec/ 21 June / 21 March
T_a = 18.8;                                                 % [C]       <- Will vary
G = [10:100:900];                                % [W/m^2]   <- Will vary
G_pu = G./1000;%max(max(G),1000);                                	% Normalised (Site data>1000)

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
MPP = [];
mpp_index = 0;
for i=1:numel(V)
    I(:,i) = G_pu.*(I_sc_0 + alpha_I) - beta.*exp(gamma.*(V(i) + alpha_V - V_oc_0));
    P(:,i) = V(i).*I(:,i).*I(:,i);
    MPP(i) = max(P(:,i).*V(i))
    if MPP(i)>max(MPP(1:i-1))
        mpp_index = i;
    end
end
    

disp('Calculations complete')


%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')        % replace with your system's monospaced font


%% Fig1 - Power Curve Simulations
if ismember(1,view) || ismember(1,output)
    fig1 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                              % Give figure useful title
            'name','Power Curve Simulations',...
            'Color','white');
    % Plot        
    linS = {'-','--',':','-.'};
    [n m] = size(P);
    for i=1:n
        plot_num = strcat('p1_',num2str(i));
        variable.(plot_num) = plot(V,P(i,:),...
        'DisplayName','Voltage vs. Power',...
        'Linestyle',linS{mod(i,numel(linS))+1},...
        'LineWidth',1.5);
        hold on
    end

    % Axis
    ax1 = gca;
    set(ax1,...
        'FontSize',14,...
        'Box','off',...
        'YMinorTick','on',...
        'XMinorTick','on',...
        'FontName',fontName,...
        'XTick',[0:5:45],...
        'Xlim',[0 45],...
        'YTick',[0:10:250],...
        'Ylim',[0 250]);
    ylabel(ax1,...
        'Power [W] \rightarrow');
    xlabel(ax1,...
        'Voltage [V] \rightarrow');

    legend1 = legend(ax1,'show');
    set(legend1,'Position',[0.0957221144144121 0.858578562632453 0.137065637065637 0.101203065657795],...
        'Box','on',...
        'EdgeColor',[1 1 1]);
    
    % Adjust figure 1
    pos_1 = get(ax1, 'Position');                             	% Current position
    pos_1(1) = 0.06;                                          	% Shift Plot horizontally
    pos_1(2) = pos_1(2) - 0.03;                             	% Shift Plot vertically
    pos_1(3) = pos_1(3)*1.17;                                 	% Scale plot horizontally
    pos_1(4) = pos_1(4)*1.1;                                  	% Scale plot vertically

    set(ax1, 'Position', pos_1);
    hold off

    disp('Finished plotting Figure 1...')
end

%% Fig2 - IV Curve Simulations
if ismember(2,view) || ismember(2,output)
    fig2 =  figure('Position',...                           % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...
            'name','IV Curve Simulations',...               % Give figure useful title
            'Color','white');
    % Plot    
    linS = {'-','--',':','-.'};
    [n m] = size(I);
    for i=1:n
        plot_num = strcat('p1_',num2str(i));
        variable.(plot_num) = plot(V,I(i,:),...
        'DisplayName','Voltage vs. Current',...
        'Linestyle',linS{mod(i,numel(linS))+1},...
        'LineWidth',1.5);
        hold on
    end
    
    % Axis
    ax2 = gca;
    set(ax2,...
        'FontSize',14,...
        'Box','off',...
        'YMinorTick','on',...
        'XMinorTick','on',...
        'FontName',fontName,...
        'XTick',[0:5:45],...
        'Xlim',[0 45],...
        'YTick',[0:3],...
        'Ylim',[0 3]);
    ylabel(ax2,...
        'Current [A] \rightarrow');
    xlabel(ax2,...
        'Voltage [V] \rightarrow');

    legend2 = legend(ax2,'show');
    set(legend2,'Position',[0.843954414328516 0.869644712608839 0.11699604743083 0.081366459627329],...
        'Box','on',...
        'EdgeColor',[1 1 1]);
    
    % Adjust Figure 2
    pos_2 = get(ax2, 'Position');                             	% Current position
    pos_2(1) = 0.08;                                          	% Shift Plot horizontally
    pos_2(2) = pos_2(2) - 0.035;                               	% Shift Plot vertically
    pos_2(3) = pos_2(3)*1.15;                                	% Scale plot horizontally
	pos_2(4) = pos_2(4)*1.1;                                   	% Scale plot vertically
    set(ax2, 'Position', pos_2);
    hold off

    disp('Finished plotting Figure 2...')
end

%% Output

disp('-------------------------')
disp(['MPP is: ',num2str(round(MPP(mpp_index),2)),' W'])
disp(['Voltage at MPP: ',num2str(round(V(mpp_index),2))])
disp(['Current at MPP: ',num2str(round(I(mpp_index),2))])
disp(' ')


if ismember(1,view) || ismember(1,output)
    set(fig1, 'Visible', 'on');
    WinOnTop( fig1, true );
end
if ismember(2,view) || ismember(2,output)
    set(fig2, 'Visible', 'on');
    WinOnTop( fig2, true );
end

if sum(view)<1
    disp('Image view disabled')
end
if sum(output)>0
	disp('Exporting images... please wait')
end

if ismember(2,output)
	export_fig ('../Report/images/IV_curves.eps',fig2)
    disp('Exported Fig2')
    close(fig2);
end
if ismember(1,output)
	export_fig ('../Report/images/Power_curves.eps',fig1)
    disp('Exported Fig1')
    close(fig1);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end

disp('Script complete')
