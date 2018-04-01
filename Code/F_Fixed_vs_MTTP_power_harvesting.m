% Simplified mathematical model
% From http://www.mdpi.com/1996-1073/9/5/326/pdf
clc; clear all; warning off; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'));

view    = [1]; % [1]
output  = [];

%% Data for GRT 21st June/December (2014/2015)
Latitude = -32.48547;
Longitude = 24.58582;
Elevation = 660; % metres

[Date_2014,~,GHI_CMP11_Jun_2014,DNI_Jun_CHP1_2014,DHI_Jun_CMP11_2014,Air_Temp_Jun_2014,...
    BP_Jun_2014,RH_Jun_2014,Rain_Jun_Tot_2014,WS_Jun_2014,WD_Jun_2014,WD_SD_Jun_2014] = importfile('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/21_June_2014.dat.txt',5, 1444);

[Date_Dec_2014,~,GHI_CMP11_Dec_2014,DNI_CHP1_Dec_2014,DHI_CMP11_Dec_2014,Air_Temp_Dec_2014,...
    BP_Dec_2014,RH_Dec_2014,Rain_Tot_Dec_2014,WS_Dec_2014,WD_Dec_2014,WD_SD_Dec_2014] = importfile('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/21_December_2014.dat.txt',5, 1444);

GHI_Max_Dec = max(max(GHI_CMP11_Dec_2014));
GHI_Max_Jun = max(max(GHI_CMP11_Jun_2014));

Air_Temp_Max_Dec = max(max(Air_Temp_Dec_2014));
Air_Temp_Min_Dec = min(min(Air_Temp_Dec_2014));

Air_Temp_Max_Jun = max(max(Air_Temp_Jun_2014));
Air_Temp_Min_Jun = min(min(Air_Temp_Jun_2014));

Air_Temp_range_Max_Delta = abs(Air_Temp_Max_Dec-Air_Temp_Max_Jun);
Air_Temp_range_Absolute = abs(Air_Temp_Max_Dec-Air_Temp_Min_Jun);;

Solar_range_Max_Delta = abs(GHI_Max_Dec-GHI_Max_Jun);
Solar_range_Absolute = GHI_Max_Dec;

Total_insolation_Dec = max(cumtrapz(GHI_CMP11_Dec_2014));
Total_insolation_Jun = max(cumtrapz(GHI_CMP11_Jun_2014));



%% Dates
try
    dateNumber = datenum(Date_2014);
    dates{1} = datetime(dateNumber, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dateNumber = datenum(Date_2014);
        dates{1} = datetime(dateNumber, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
    catch
        dates{1} = repmat(datetime([NaN NaN NaN]), size(Date_2014));
    end
end

try
    dateNumber_Dec = datenum(Date_Dec_2014);
    dates_Dec{1} = datetime(dateNumber_dec, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dateNumber_Dec = datenum(Date_Dec_2014);
        dates_Dec{1} = datetime(dateNumber_Dec, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
    catch
        dates_Dec{1} = repmat(datetime([NaN NaN NaN]), size(Date_Dec_2014));
    end
end

DateStep = minutes(1);
startDate = dates{1}(1);
endDate = dates{1}(end);
allDates = (startDate:DateStep:endDate)';
allDatesNum = datenum(allDates);
XTickIndex = datenum([startDate:hours(2):endDate]);
XTickLimit = datenum([startDate endDate]);


%% Simulation Parameter input
% 21 Dec/ 21 June / 21 March

% From datasheet for TSM-300 PA14 at STC
P_max = 300;                                                % [W]
V_mp_0 = 36.9;                                              % [V]
I_mp_0 = 8.13;                                              % [A]
V_oc_0 = 45.3;                                              % [V]
I_sc_0 = 8.60;                                              % [A]
eta = 0.155;                                                % 15.5 percent efficiency

panel_area = (1.956*0.992);                                 % m^2
panel_area_total = 3 * panel_area;                          % m^2

% Site Data
G = [GHI_CMP11_Jun_2014];                                   % W/m^2
T_a = [Air_Temp_Jun_2014];                     % [C]

G_pu = G./max(G);                                             % Normalised (Site data>1000)

% Temperature coefficients
alpha_P_sc = -0.44/100;                                  	% percentage/�C
alpha_I_sc = -0.33/100;                                    	% percentage/�C, short-circuit current
alpha_V_oc = 0.046/100;                                    	% percentage/�C, open-circuit voltage

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

I = G_pu.*(I_sc_0 + alpha_I) - beta.*exp(gamma.*(V_oc + alpha_V - V_oc_0));

R_fixed = 10;

% Total_voltage = V_o.*number_modules;

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

%% Fig1 - IV Curve Simulations
if ismember(1,view) || ismember(1,output)
    fig1 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                              % Give figure useful title
            'name','IV Curve Simulations',...
            'Color','white');
    % Plot    
    linS = {'-','--',':','-.'};
    [n m] = size(I);
    for i=1:n
        plot_num = strcat('p1_',num2str(i));
        variable.(plot_num) = plot(I,... %         'DisplayName',labels{i}
        'Linestyle','-',... %linS{mod(i,numel(linS))+1}
        'LineWidth',1.5);
    
        hold on
    end
    
    % Axis
    ax1 = gca;
%     set(ax1,...
%         'FontSize',14,...
%         'Box','off',...
%         'YMinorTick','on',...
%         'XMinorTick','on',...
%         'FontName',fontName,...
%         'XTick',[0:5:50],...
%         'Xlim',[0 50],...
%         'YTick',[0:8],...
%         'Ylim',[0 8]);
%     ylabel(ax1,...
%         'Current [W] \rightarrow');
%     xlabel(ax1,...
%         'Voltage [V] \rightarrow');

%     legend1 = legend(ax1,'show');
%     set(legend1,'Position',[0.0957221144144121 0.858578562632453 0.137065637065637 0.101203065657795],...
%         'Box','on',...
%         'EdgeColor',[1 1 1]);
    
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

%% Output
disp(' ')
disp('-------------------------')
% [n m]  = size(P);
% for i=1:n
% disp([labels{i},':'])
% disp(['MPP is: ',num2str(round(MPP(i),2)),' W'])
% disp(['Voltage at MPP: ',num2str(round(V(mpp_index(i)),2))])
% disp(['Current at MPP: ',num2str(round(I(i,mpp_index(i)),2))])
% disp(['Load at MPP: ',num2str(round(R(i,mpp_index(i)),2))])
% disp(['Confirm Load at MPP: ',num2str(round(Load(i),2))])
% disp(' ')
% end
% disp('-------------------------')
% disp(' ')


if ismember(1,view) || ismember(1,output)
    set(fig1, 'Visible', 'on');
    WinOnTop( fig1, true );
end

if sum(view)<1
    disp('Image view disabled')
end
if sum(output)>0
	disp('Exporting images... please wait')
end

% if ismember(1,output)
% 	export_fig ('../Report/images/Power_curves.eps',fig1)
%     disp('Exported Fig1')
%     close(fig1);
% end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end

disp('Script complete')
