clc; clear all;

Latitude = -32.7849026;
Longitude = 26.8454793;

%% Import the data
[~, ~, raw] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017.xlsx','AnnualSunPath_2017');
raw_sundata = raw(2:end,2:end);
raw_time = raw(1,2:end);
raw_date = raw(2:end,1);

%% Prepare and split data
% raw_time(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw_time)) = {''};
R = cellfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),raw_sundata); % Find non-numeric cells
raw_sundata(R) = {NaN}; % Replace non-numeric cells

% Time
[n m] = size(raw_sundata);
i=1;
for j=1:2:m-1
    str = raw_time{1,j};
    Time{1,i} = str(3:end-3);
    raw_elevation(:,i) = [raw_sundata{:,j}]';
    raw_azimuth(:,i)   = [raw_sundata{:,j+1}]';
    i = i+1;
end

%% Annual data %%
raw_date = reshape([raw_date{:}],size(raw_date));

%% Azimuth and Elevation
i=1;
for j=1:length(raw_elevation)
    SunElevationYearMax(j,:) = max(raw_elevation(j,:));
    SunAzimuthYear_min = deg2rad(min(raw_azimuth(j,:)));
    DateYear(j) = raw_date(j);
    SunAzimuthYearMin(j,:) = rad2deg(unwrap(SunAzimuthYear_min));
    i = i + 1;
end

%% Zenith
i=1;
for j=sort([5 6 7 8 9 10 11 12])  % from 6am to 12pm
    TimeZenith{1,i} = Time{1,(j*6)+1};
    SunZenithYear(:,i) = raw_elevation(:,(j*6));    % Time columns in increments of 10 min
	i = i + 1;
end
R1 = arrayfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),SunZenithYear); % Find non-numeric cells
SunZenithYear(R1) = (0); % Replace non-numeric cells
SunZenithYear = 90 - SunZenithYear;

%% Equinoxes and Solstices
% March 21 - Autumn - Day 80 / % September 21 Spring - Day 264
% June 21 - Winter - Day 172
% December 21 - Summer - Day 355
days =[80,172,355]; % Solstices and Equinox
i=1;
for k=1:length(days)
    SunElevationDay(i,:) = raw_elevation(days(k),:);
    SunAzimuthDay_temp = deg2rad(raw_azimuth(days(k),:));
    DateDay(i) = raw_date(k);
    SunAzimuthDay(i,:) = rad2deg(unwrap((SunAzimuthDay_temp)));
    i = i + 1;
end

%% Dates
dateMonth = datetime(DateYear,'ConvertFrom','excel','Format','MMMM');
dateMonthDay = datetime(DateYear,'ConvertFrom','excel','Format','MMMM dd');
time = datetime(Time,'InputFormat','HH:mm','Format','HH:mm');

%% Equation of Solar Time
% syms delta_time n;
% delta_time(n) = 9.873*sin( (4*pi / 365.242) * ( n - 81 )) - 7.655*sin( (2*pi / 365.242)* ( n - 1 ));
days = [1:366];
% equation_time = delta_time(days);

%% Tilt Angle
date_days = [1:366];
d_angle = degtorad(360./365.*date_days + 284);
DeclinationAngle = -23.45 * sin(d_angle);
TiltOptimal = -(Latitude-DeclinationAngle);
TiltAverage = sum(TiltOptimal)/numel(TiltOptimal);

disp('Finished Output Variable preperation');

%% Clear temporary variables
% clearvars raw_sundata raw_azimuth raw_elevation raw_time raw_date R i j k str;
% clearvars SunElevationDay_temp SunAzimuthDay_temp;

disp('Cleared temp variables');

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')        % replace with your system's monospaced font

%% Fig1
fig1 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig1,'numbertitle','off',...                            % Give figure useful title
        'name','Solar Altitude Angle (Daily)',...
        'Color','white');
% Plot    
[n m] = size(SunAzimuthDay);
for i=1:n
    plot_num = strcat('p1_',num2str(i));
    variable.(plot_num) = plot(SunAzimuthDay(i,:),SunElevationDay(i,:),...
	'LineWidth',2);
hold on
end
% Axis
ax1 = gca;
set(ax1,...
    'FontSize',14,...
    'YMinorTick','on',...
    'XMinorTick','on',...
    'FontName',fontName,...
    'Box','off',...
    'XTick',[-180:30:180],...
    'Xlim',[-180 180],...
    'Ylim',[0 90]);
ylabel(ax1,...
    'Solar Elevation Angle (deg)');
xlabel(ax1,...
    'Solar Azimuth Angle (deg)');

% Ticks formatting 
xt=get(ax1,'xtick');
for k=1:numel(xt);
xt1{k}=sprintf('%d°',xt(k));
end
set(ax1,'xticklabel',xt1);
yt=get(ax1,'ytick');
for k=1:numel(yt);
yt1{k}=sprintf('%d°',yt(k));
end
set(ax1,'yticklabel',yt1);
a1_1 = annotation('textbox',[0.467 0.88 0.0767 0.0348],...
        'String',{'21 December'},...
        'LineStyle','none',...
        'FitBoxToText','on',...
        'BackgroundColor','white',...
        'FontSize',12,...
        'FontName',fontName);
a1_2 = annotation('textbox',[0.453 0.676 0.111 0.0348],...
        'String',{'21 March/September'},...
        'LineStyle','none',...
        'FitBoxToText','on',...
        'BackgroundColor','white',...
        'FontSize',12,...
        'FontName',fontName);hold off
a1_3 = annotation('textbox',[0.483 0.475 0.0531 0.0348],...
        'String',{'21 June'},...
        'LineStyle','none',...
        'FitBoxToText','on',...
        'BackgroundColor','white',...
        'FontSize',12,...
        'FontName',fontName);
    
% Adjust figure 1
pos_1 = get(ax1, 'Position');                                 % Current position
pos_1(1) = 0.08;                                              % Shift Plot horizontally
pos_1(2) = pos_1(2) + 0.03;                                   % Shift Plot vertically
pos_1(3) = pos_1(3)*1.1;                                      % Scale plot vertically
set(ax1, 'Position', pos_1);
hold off

disp('Finished Fig1')

%% Fig2
fig2 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig2,'numbertitle','off',...                            % Give figure useful title
        'name','Solar Azimith Angle',...
        'Color','white');
% Plot

for i=1:n
    plot_num = strcat('p2_',num2str(i));
    variable.(plot_num) = plot(time,SunAzimuthDay(i,:),...
	'LineWidth',2);
hold on
end

% Axis
ax2 = gca;
set(ax2,...
    'FontSize',14,...
    'FontName',fontName,...
    'Box','off',...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'XTick',...
    [737149.125:0.125:737149.875],...
    'Xlim',[737149.125 737149.875],...
    'XTickLabel',...
    {'03:00','06:00','09:00','12:00','15:00','18:00','21:00'},...
    'YTick',[-180:30:180],...
    'Ylim',[-180 180]);
ylabel(ax2,...
    'Solar Azimuth Angle');
xlabel(ax2,...
    'Time \rightarrow');

% Ticks formatting 
yt=get(ax2,'ytick');
for k=1:numel(yt);
yt2{k}=sprintf('%d°',yt(k));
end
set(ax2,'yticklabel',yt2);
legend2 = legend(ax2,...
    {'21 March/September','21 June','21 December'},...
    'Location','best',...
    'EdgeColor',[1 1 1],...
	'Box','off');
reorderLegend([1,3,2],ax2);

% Adjust Figure 2
pos_2 = get(ax2, 'Position');                                 % Current position
pos_2(1) = 0.08;                                              % Shift Plot horizontally
pos_2(2) = pos_2(2) + 0.03;                                   % Shift Plot vertically
pos_2(3) = pos_2(3)*1.2;                                      % Scale plot vertically
set(ax1, 'Position', pos_2);
hold off

disp('Finished Fig2')

%% Fig3
fig3 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig3,'numbertitle','off',...                            % Give figure useful title
        'name','Annual Solar Azimuth (Minimum)',...
        'Color','white');

p3_1 = plot(dateMonth,SunAzimuthYearMin,...
	'Color',[0.18 0.18 0.9 .6],...                          % [R G B Alpha]
	'LineStyle','-',...
	'LineWidth',2);

% Axis
ax3 = gca;
set(ax3,...
    'FontSize',14,...
    'FontName',fontName,...
    'Box','off',...
    'XMinorTick','off',...
    'YMinorTick','on',...
    'XGrid','off',...
    'XTick',[736696 736755 736816 736877 736939 737000 737060],...
    'Xlim',[736696 737060],...
    'XTickLabel',{'Jan','Mar','May','Jul','Sep','Nov','Dec'},...
    'YTick',[0:5:20],...
    'Ylim',[0 20]);
ylabel(ax3,...
    'Minimim Solar Azimuth Angle (deg)');
xlabel(ax3,...
    'Date \rightarrow');

% Adjust Figure 3
pos_3 = get(ax3, 'Position');                                 % Current position
pos_3(1) = 0.08;                                              % Shift Plot horizontally
pos_3(2) = pos_3(2) + 0.03;                                   % Shift Plot vertically
pos_3(3) = pos_3(3)*1.1;                                      % Scale plot vertically
set(ax1, 'Position', pos_3);
hold off

disp('Finished Fig3')

%% Fig4
fig4 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig4,'numbertitle','off',...                            % Give figure useful title
        'name','Annual Zenith',...
        'Color','white');

% plot
[n m] = size(SunZenithYear);
for i=1:m
    plot_num = strcat('p4_',num2str(i));
    variable.(plot_num) = plot(dateMonthDay,SunZenithYear(:,i),...
	'LineWidth',2);
    hold on
end

% Axis
ax4 = gca;
set(ax4,...
    'FontSize',14,...
    'FontName',fontName,...
    'Box','on',...
    'XMinorTick','off',...
    'YMinorTick','on',...
    'XGrid','off',...
    'XTick',[736696 736755 736816 736877 736939 737000 737060],...
    'Xlim',[736696 737060],...
    'XTickLabel',{'Jan','Mar','May','Jul','Sep','Nov','Dec'},...
    'YTick',[0:30:100],...
    'Ylim',[0 100]);
ylabel(ax4,...
    'Solar Zenith Angle (deg)');
xlabel(ax4,...
    'Date \rightarrow');
hold off

% Ticks formatting 
yt=get(ax4,'ytick');
for k=1:numel(yt);
yt4{k}=sprintf('%d°',yt(k));
end
set(ax4,'yticklabel',yt4);
legend4 = legend(ax4,...
    TimeZenith,...
    'Position',[0.4566 0.2555 0.0700 0.1970],...
    'Location','best',...
    'EdgeColor',[1 1 1],...
	'Box','off');
% reorderLegend([1,3,2],ax4);

pos_4 = get(ax4, 'Position');                                 % Current position
pos_4(1) = 0.08;                                              % Shift Plot horizontally
pos_4(2) = pos_4(2) + 0.03;                                   % Shift Plot vertically
pos_4(3) = pos_4(3)*1.1;                                      % Scale plot vertically
set(ax4, 'Position', pos_4)
hold off

disp('Finished Fig4')

%% Fig5
fig5 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig5,'numbertitle','off',...                            % Give figure useful title
        'name','Annual Zenith',...
        'Color','white');

% plot
p5_1 = plot(dateMonthDay,TiltOptimal,...
	'Color',[0.18 0.18 0.9 .6],...                          % [R G B Alpha]
	'LineStyle','-',...
	'LineWidth',2);
hold on
p5_2 = refline(0,TiltAverage);
set(p5_2,'Color',[0.9 0.18 0.18 .6],...                 
        'LineStyle','-',...
        'LineWidth',2);
hold on
% Axis
ax5 = gca;
set(ax5,...
    'FontSize',14,...
    'FontName',fontName,...
    'Box','on',...
    'XMinorTick','off',...
    'YMinorTick','on',...
    'XGrid','off',...
    'XTick',[736696 736755 736816 736877 736939 737000 737060],...
    'Xlim',[736696 737060],...
    'XTickLabel',{'Jan','Mar','May','Jul','Sep','Nov','Dec'},...
    'YTick',sort([0:6:60 round(TiltAverage,2)]),...
    'Ylim',[0 60]);
ylabel(ax5,...
    'Tilt Angle (deg)');
xlabel(ax5,...
    'Date \rightarrow');

% Ticks formatting
% ax5.YAxis.TickLabelFormat = '%,.1f';
yt=get(ax5,'ytick');
for k=1:numel(yt);
yt5{k}=sprintf('%.2f°',yt(k));
end
set(ax5,'yticklabel',yt5);
legend5 = legend(ax5,...
    {'Optimal Tilt Angle','Average Tilt Angle'},...
    'Position',[0.739 0.234 0.142 0.0782],...
    'Location','best',...
    'EdgeColor',[1 1 1],...
	'Box','off');

pos_5 = get(ax5, 'Position');                                 % Current position
pos_5(1) = 0.08;                                              % Shift Plot horizontally
pos_5(2) = pos_5(2) + 0.03;                                   % Shift Plot vertically
pos_5(3) = pos_5(3)*1.1;                                      % Scale plot vertically
set(ax5, 'Position', pos_5)
hold off

disp('Finished Fig5')

%% Output
set(fig1, 'Visible', 'on');
set(fig2, 'Visible', 'on');
set(fig3, 'Visible', 'on');
set(fig4, 'Visible', 'on');
set(fig5, 'Visible', 'on');

% export (fix for missing CMU fonts in eps export)
export_fig ('../Report/images/Solar_Altitude_Daily.eps',fig1)
export_fig ('../Report/images/Solar_Azimith_Angle_Daily.eps',fig2)
export_fig ('../Report/images/Solar_Azimith_Min_Annual.eps',fig3)
export_fig ('../Report/images/Solar_Zenith_Annual.eps',fig4)
export_fig ('../Report/images/Optimal_Tilt_Angle.eps',fig5)

disp('Images exported')


