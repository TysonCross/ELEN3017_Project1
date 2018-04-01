% Simplified mathematical model
% From http://www.mdpi.com/1996-1073/9/5/326/pdf
clc; clear all; warning off; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'));

view    = [1 2]; % [1 2]
output  = view;

%% Data for GRT 21st June/December (2014/2015)
Latitude = -32.48547;
Longitude = 24.58582;
Elevation = 660; % metres

variable_EnergyTemp; % load energy and temperature values for simulation
%{
    The following variables are loaded:

    GHI_CMP11_Dec_2014
    GHI_Max_Dec
    Air_Temp_Max_Dec
    Air_Temp_Min_Dec

    GHI_CMP11_Jun_2014
    GHI_Max_Jun
    Air_Temp_Max_Jun
    Air_Temp_Min_Jun

    Air_Temp_range_Max_Delta
    Air_Temp_range_Absolute
    Total_insolation_Dec
    Total_insolation_Jun
    Solar_range_Max_Delta
    Solar_range_Absolute
%}

variable_Angles; % load solar angles
%{
    Tilt_angle_optimal
    Tilt_angle_max
    Tilt_angle_min
    Tilt_angle_optimal_mean
    Tilt_angle_optimal_weighted
    SunZenithAngleSimple
    SunZenithAngle
    DeclinationAngle
%}

DateStep = minutes(1);
startDate_jun = datetime(735771, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
endDate_jun = datetime(735771.9993, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
allDates = (startDate_jun:DateStep:endDate_jun)';
allDatesNum = datenum(allDates);

% labels = {'200 W/m^2','400 W/m^2','600 W/m^2','800 W/m^2','1000 W/m^2'}

%% Simulation Parameter input
% 21 Dec/ 21 June / 21 March

% From datasheet for TSM-300 PA14 at STC
P_max = 300;                                                % [W]
V_mp_0 = 36.9;                                              % [V]
I_mp_0 = 8.13;                                              % [A]
V_oc_0 = 45.3;                                              % [V]
I_sc_0 = 8.60;                                              % [A]
eta = 0.155;                                                % 15.5 percent efficiency

panel_number = 3;
panel_area = (1.956*0.992);                                 % m^2
panel_area_total = panel_number * panel_area;             	% m^2

% Site Data
% T_a = 18.8;                                                   % [C] 
G = [max(GHI_CMP11_Dec_2014); mean(GHI_CMP11_Dec_2014);...
    mean(GHI_CMP11_Jun_2014);max(GHI_CMP11_Jun_2014)];      % W/m^2
T_a = [Air_Temp_Max_Dec;Air_Temp_Min_Dec;...
    Air_Temp_Max_Jun;Air_Temp_Min_Jun];                     % [C]
% T_a = [25:5:45];                                          % [C]
% G = [200:200:1000];                                       % W/m^2
G_pu = G./max(G);                                             % Normalised (Site data>1000)

% Temperature coefficients
alpha_P_sc = -0.44/100;                                  	% percentage/°C
alpha_I_sc = -0.33/100;                                    	% percentage/°C, short-circuit current
alpha_V_oc = 0.046/100;                                    	% percentage/°C, open-circuit voltage

% Operating Temperature of a cell
% (relates disparity between NOTC and STC)
NOCT = 45;                                                  % [C]
T_c = T_a + G./800.*(NOCT-20);
delta_T = T_c-25;

% For a single module made of multiple cells, connected in series
N_s = 72;                                                   % <- must check
N_p = 1;                                                    % <- must check

number_modules = 3;
alpha_I = alpha_I_sc.*delta_T;
alpha_V = alpha_V_oc.*delta_T;

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

%% Energy and power harvesting
% Fixed:
b_angle = deg2rad(90-SunZenithAngle([172 355]) + Tilt_angle_optimal_weighted);
Max_solar_energy_Dec = GHI_Max_Dec*sin(b_angle(2));
Max_solar_energy_Jun = GHI_Max_Dec*sin(b_angle(1));
Average_solar_energy_day = (Max_solar_energy_Dec+Max_solar_energy_Jun)/2; % per day
Average_solar_energy_year = Average_solar_energy_day*365; % per year
Energy_harvested_max = Average_solar_energy_year * panel_area_total * eta; % captured
Energy_harvested_realistic = Energy_harvested_max * 0.75;

% MTTP:

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

% labels = {'Unoccluded summer noon','Occluded summer noon','Unoccluded winter noon','Occluded winter noon'};
labels{1} = strcat('Unoccluded summer noon:', num2str(round(G(1))),' W/m^2');
labels{2} = strcat('Occluded summer noon:', num2str(round(G(2))),' W/m^2');
labels{3} = strcat('Unoccluded winter noon:', num2str(round(G(3))),' W/m^2');
labels{4} = strcat('Occluded winter noon: ', num2str(round(G(4))),' W/m^2');

for i=1:numel(mpp_index)
    mpplabelsIV{i} = strcat('MPP (', num2str(round(V(mpp_index(i)),2)),{','},num2str(round(I(i,mpp_index(i)),2)),')');
    mpplabelsPV{i} = strcat('MPP (', num2str(round(V(mpp_index(i)),2)),{','},num2str(round(P(i,mpp_index(i)),2)),')');
end

%% Fig1 - PV Curve Simulations
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
        'DisplayName',labels{i},...
        'Linestyle','-',... %linS{mod(i,numel(linS))+1}
        'LineWidth',1.5);
        hold on
        
        x_pos = V(mpp_index(i));
        y_pos = P(i,double(mpp_index(i)));
        
        ref_num = strcat('r1_',num2str(i));
        variable.(ref_num) = plot(x_pos,y_pos,'o');
        set(variable.(ref_num),...
        'Color',[0.18 0.18 0.18],...
        'DisplayName','',...
        'MarkerSize',6,...
        'MarkerFaceColor',[0.18 0.18 0.18],...
        'Linestyle','-',...
        'LineWidth',1.5);
        hold on
        
        offset_x = -3;
        offset_y = 10;
        ann_num = strcat('a2_',num2str(i));
        variable.(ann_num) = text(x_pos+offset_x, y_pos+offset_y, mpplabelsPV{i},...
            'Color',[0.18 0.18 0.18],...
            'FontSize',12,...
            'FontName',fontName);
    end
    
    % Axis
    ax1 = gca;
    set(ax1,...
        'FontSize',14,...
        'Box','off',...
        'YMinorTick','on',...
        'XMinorTick','on',...
        'FontName',fontName,...
        'XTick',[0:5:50],...
        'Xlim',[0 50],...
        'YTick',[0:50:310],...
        'Ylim',[0 310]);
    ylabel(ax1,...
        'Power [W] \rightarrow');
    xlabel(ax1,...
        'Voltage [V] \rightarrow');

    legend1 = legend(ax1,'show');
    set(legend1,'Position',[0.0954496654649517 0.84581911460007 0.239382239382239 0.119744085320292],...
        'Box','on',...
        'EdgeColor',[1 1 1]);
    legend1.PlotChildren = legend1.PlotChildren([1 3 5 7]);

    
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
        plot_num = strcat('p2_',num2str(i));
        variable.(plot_num) = plot(V,I(i,:),...
        'DisplayName',labels{i},...
        'Linestyle','-',... %linS{mod(i,numel(linS))+1}
        'LineWidth',1.5);
        hold on
         
        x_pos = V(mpp_index(i));
        y_pos = I(i,double(mpp_index(i)));
        
        ref_num = strcat('r2_',num2str(i));
        variable.(ref_num) = plot(x_pos,y_pos,'o');
        set(variable.(ref_num),...
        'DisplayName','',...
        'Color',[0.18 0.18 0.18],...
        'MarkerSize',6,...
        'MarkerFaceColor',[0.18 0.18 0.18],...
        'Linestyle','-',...
        'LineWidth',1.5);
        hold on
        
        offset_x = -0.6;
        offset_y = 0.26;
        ann_num = strcat('a2_',num2str(i));
        variable.(ann_num) = text(x_pos+offset_x,y_pos+offset_y,mpplabelsIV{i},...
            'Color',[0.18 0.18 0.18],...
            'FontSize',12,...
            'FontName',fontName);
    end
    
    % Axis
    ax2 = gca;
    set(ax2,...
        'FontSize',14,...
        'Box','off',...
        'YMinorTick','on',...
        'XMinorTick','on',...
        'FontName',fontName,...
        'XTick',[0:5:50],...
        'Xlim',[0 50],...
        'YTick',[0:10],...
        'Ylim',[0 10]);
    ylabel(ax2,...
        'Current [A] \rightarrow');
    xlabel(ax2,...
        'Voltage [V] \rightarrow');

    a2_1a = annotation('textbox',[0.0961796067500641 0.839090836378138 0.219691769438439 0.0432623792124927],...
            'String',labels{1},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);
    a2_1b = annotation('textbox',[0.0961796067500641 0.468221659415665 0.200378207290005 0.0432623792124927],...
            'String',labels{2},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);
    a2_1c = annotation('textbox',[0.0961796067500641 0.176061646075057 0.202792402558559 0.0432623792124927],...
            'String',labels{3},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);
    a2_1d = annotation('textbox',[0.0961796067500641 0.347566077953153 0.189755748108366 0.0432623792124927],...
            'String',labels{4},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);
    
%     a2_2a = annotation('textbox',[0.745587241865814 0.798158071555653 0.0932158469372744 0.0210073071151357],...
%             'String',mpplabels{1},...
%             'LineStyle','none',...
%             'FitBoxToText','on',...
%             'BackgroundColor','white',...
%             'FontSize',12,...
%             'FontName',fontName);
%     a2_2b = annotation('textbox',[0.745587241865814 0.456556060489419 0.0864590901805178 0.0179416211180002],...
%             'String',mpplabels{2},...
%             'LineStyle','none',...
%             'FitBoxToText','on',...
%             'BackgroundColor','white',...
%             'FontSize',12,...
%             'FontName',fontName);
%     a2_2c = annotation('textbox',[0.744621990900563 0.342356474605942 0.0719803257017505 0.0177671729983855],...
%             'String',mpplabels{3},...
%             'LineStyle','none',...
%             'FitBoxToText','on',...
%             'BackgroundColor','white',...
%             'FontSize',12,...
%             'FontName',fontName);
%     a2_2d = text('textbox',[0.744621990900563 0.180122042476874 0.0825980863195146 0.0223509096096795],...
%             'String',mpplabels{4},...
%             'LineStyle','none',...
%             'FitBoxToText','on',...
%             'BackgroundColor','white',...
%             'FontSize',12,...
%             'FontName',fontName);
    
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
disp(' ')
disp('-------------------------')
%     [MPP(i) mpp_index(i)] = max(P(i,:));

[n m]  = size(P);
for i=1:n
disp([labels{i},':'])
disp(['MPP is: ',num2str(round(MPP(i),2)),' W'])
disp(['Voltage at MPP: ',num2str(round(V(mpp_index(i)),2))])
disp(['Current at MPP: ',num2str(round(I(i,mpp_index(i)),2))])
disp(['Load at MPP: ',num2str(round(R(i,mpp_index(i)),2))])
disp(' ')
end

disp(['Average solar energy striking tilted surface: ',...
    num2str(round(Average_solar_energy_day/1000,2)),' kW/day']); % total Average striking surface
disp(['Average_solar_energy striking tilted surface ',...
    num2str(round(Average_solar_energy_year/1000,2)),' kW/year']); % total Average striking surface in a year
disp(['Maximal energy harvested is ',...
    num2str(round(Energy_harvested_max/1000,2)),' kW/year']); % Total captured on tilted panel
disp(['Accounting for occlusion, the maximum harvested energy is ',...
    num2str(round(Energy_harvested_realistic/1000,2)),' kW/year']); % Allowing for weather

disp('-------------------------')
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
	export_fig ('../Report/images/PV_curves.eps',fig1)
    disp('Exported Fig1')
    close(fig1);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end

disp('Script complete')
