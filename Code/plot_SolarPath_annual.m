
clc; clear all;
%% Import the data
[~, ~, raw_sundata] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017_1522312124298 10min.xlsx','SunEarthTools_AnnualSunPath_201');
raw_sundata = raw_sundata(2:end,2:end);

[~, ~, raw_time] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017_1522312124298 10min.xlsx','SunEarthTools_AnnualSunPath_201');
raw_time = raw_time(1,2:end);

[~, ~, raw_date] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017_1522312124298 10min.xlsx','SunEarthTools_AnnualSunPath_201');
raw_date = raw_date(2:end,1);


%% Prepare and split data
% raw_time(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw_time)) = {''};
R = cellfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),raw_sundata); % Find non-numeric cells
raw_sundata(R) = {NaN}; % Replace non-numeric cells

[n m] = size(raw_sundata);
i=1;
for j=1:2:m-1
    str = raw_time{1,j};
    Time{1,i} = str(3:end);
    raw_elevation(:,i) = [raw_sundata{:,j}]';
    raw_azimuth(:,i)   = [raw_sundata{:,j+1}]';
    i = i+1;
end

%% Annual data 
raw_date = reshape([raw_date{:}],size(raw_date));

for k=1:length(raw_elevation)
    SunElevationYearMax(k,:) = max(raw_elevation(k,:));
    SunAzimuthYear_min = deg2rad(min(raw_azimuth(k,:)));
    DateYear(k) = raw_date(k);
    SunAzimuthYearMin(k,:) = rad2deg(unwrap(SunAzimuthYear_min));
end

%% Equinoxes and Solstices
% March 21 - Autumn - Day 80 / % September 21 Spring - Day 264
% June 21 - Winter - Day 172
% December 21 - Summer - Day 355
days =[80,172,355];
i=1;
for k=1:length(days)
    SunElevationDay(i,:) = raw_elevation(days(k),:);
    SunAzimuthDay_temp = deg2rad(raw_azimuth(days(k),:));
    DateDay(i) = raw_date(k);
    SunAzimuthDay(i,:) = rad2deg(unwrap((SunAzimuthDay_temp)));
	for j=6:12 
        SunElevationYear(i,j-5) = raw_elevation(k,(j*6)+1); 
        SunAzimuthYear_temp = deg2rad(raw_azimuth(k,(j*6)+1)); 
        SunAzimuthYear(i,j-5) = rad2deg(unwrap(SunAzimuthYear_temp)); 
    end 
    i = i + 1;
end

% Equation of Solar Time
% syms delta_time n;
% delta_time(n) = 9.873*sin( (4*pi / 365.242) * ( n - 81 )) - 7.655*sin( (2*pi / 365.242)* ( n - 1 ));
% days = [1:365];
% equation_time = delta_time(days);

% Declination Angle
DeclinationAngle = 23.45 * sin((360/365)*(DateDay + 284));

%% Clear temporary variables
clearvars raw_sundata raw_azimuth raw_elevation raw_time raw_date R i j k str;
clearvars SunElevationDay_temp SunAzimuthDay_temp;

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
	'LineWidth',1);
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
    'XTick',[-180:40:180],...
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

%% Fig2
fig2 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig2,'numbertitle','off',...                            % Give figure useful title
        'name','Solar Azimith Angle',...
        'Color','white');
% Plot
time = datetime(Time,'InputFormat','HH:mm:ss','Format','HH:mm');

for i=1:n
    plot_num = strcat('p2_',num2str(i));
    variable.(plot_num) = plot(time,SunAzimuthDay(i,:),...
	'LineWidth',1);
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
    [737149.250:0.125:737149.875],...
    'Xlim',[737149.250 737149.875],...
    'XTickLabel',...
    {'06:00','09:00','12:00','15:00','18:00','21:00'},...
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

%% Fig3
fig3 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig3,'numbertitle','off',...                            % Give figure useful title
        'name','Annual Solar Azimuth (Minimum)',...
        'Color','white');
    
date = datetime(DateYear,'ConvertFrom','excel','Format','MMMM');

p3_1 = plot(date,SunAzimuthYearMin,...
	'Color',[0.18 0.18 0.9 .6],...                          % [R G B Alpha]
	'LineStyle','-',...
	'LineWidth',1);

% Axis
ax3 = gca;
set(ax3,...
    'FontSize',14,...
    'FontName',fontName,...
    'Box','off',...
    'XMinorTick','off',...
    'YMinorTick','on',...
    'XGrid','on',...
    'XTick',[736696 736755 736816 736877 736939 737000 737060],...
    'Xlim',[736696 737060],...
    'XTickLabel',{'Jan','Mar','May','Jul','Sep','Nov','Dec'},...
    'YTick',[0:5:30],...
    'Ylim',[0 30]);
ylabel(ax3,...
    'Annual Solar Azimuth');
xlabel(ax3,...
    'Date \rightarrow');

% Adjust Figure 3
pos_3 = get(ax3, 'Position');                                 % Current position
pos_3(1) = 0.08;                                              % Shift Plot horizontally
pos_3(2) = pos_3(2) + 0.03;                                   % Shift Plot vertically
pos_3(3) = pos_3(3)*1.1;                                      % Scale plot vertically
set(ax1, 'Position', pos_3);
hold off

%% Fig4
fig4 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off');
set(fig4,'numbertitle','off',...                            % Give figure useful title
        'name','Annual Zenith',...
        'Color','white');
ax4 = gca;
p4_1 = plot(date,90-SunElevationYearMax,...
    'Color',[0.18 0.18 0.9 .6],...                          % [R G B Alpha]
	'LineStyle','-',...
	'LineWidth',1);
set(ax4,...
    'FontSize',14,...
    'FontName',fontName,...
    'Box','off',...
    'XMinorTick','off',...
    'YMinorTick','on',...
    'XGrid','on',...
    'XTick',[736696 736755 736816 736877 736939 737000 737060],...
    'Xlim',[736696 737060],...
    'XTickLabel',{'Jan','Mar','May','Jul','Sep','Nov','Dec'},...
    'YTick',[0:10:60],...
    'Ylim',[0 60]);
ylabel(ax4,...
    'Annual Sun Zenith Angle (deg)');
xlabel(ax4,...
    'Date \rightarrow');
hold off

% Global Axes and labels
% set(findobj(gcf,'type','axes'),...
hold off


pos_4 = get(ax4, 'Position');                                 % Current position
pos_4(1) = 0.08;                                              % Shift Plot horizontally
pos_4(2) = pos_4(2) + 0.03;                                   % Shift Plot vertically
pos_4(3) = pos_4(3)*1.1;                                      % Scale plot vertically
set(ax1, 'Position', pos_4)
hold off

set(fig1, 'Visible', 'on');
set(fig2, 'Visible', 'on');
set(fig3, 'Visible', 'on');
set(fig4, 'Visible', 'on');

% export (fix for missing CMU fonts in eps export)
% export_fig ('../Report/images/Solar_Altitude_Daily.eps',fig1)
export_fig ('../Report/images/Solar_Azimith_Angle_Daily.eps',fig2)

