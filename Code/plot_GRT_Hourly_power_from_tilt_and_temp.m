% GRT Expected Power output & Average Air Temperature (Hourly) 
clc; clear all; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); warning off;

view    = [1 3]; % [1 2 3]
output  = [];

%% Data for GRT 1/1/14-1/1/15
Latitude = -32.48547;
Longitude = 24.58582;
Elevation = 660; % metres

%% Initialize variables.
filename_H = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20130901_GRT_H.dat.txt';
DateStep = hours(1);
delimiter1 = ',';
startRow1 = 5;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID1 = fopen(filename_H,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray_H = textscan(fileID1, formatSpec, 'Delimiter', delimiter1, 'HeaderLines' ,startRow1-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID1);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw_data_H = repmat({''},length(dataArray_H{1}),length(dataArray_H)-1);
for col1=1:length(dataArray_H)-1
    raw_data_H(1:length(dataArray_H{col1}),col1) = dataArray_H{col1};
end
numericData1 = NaN(size(dataArray_H{1},1),size(dataArray_H,2));

for col1=[2,3,4,5,6,7,8]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData1 = dataArray_H{col1};
    for row=1:size(rawData1, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr1 = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result1 = regexp(rawData1{row}, regexstr1, 'names');
            numbers1 = result1.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator1 = false;
            if any(numbers1==',');
                thousandsRegExp1 = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers1, thousandsRegExp1, 'once'));
                    numbers1 = NaN;
                    invalidThousandsSeparator1 = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator1;
                numbers1 = textscan(strrep(numbers1, ',', ''), '%f');
                numericData1(row, col1) = numbers1{1};
                raw_data_H{row, col1} = numbers1{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using date
% format string.
try
    data_dateNumber_H = datenum(dataArray_H{1});
    dates_H{1} = datetime(data_dateNumber_H, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dataArray_H{1} = cellfun(@(x) x(2:end-1), dataArray_H{1}, 'UniformOutput', false);
        data_dateNumber_H = datenum(dataArray_H{1});
        dates_H{1} = datetime(data_dateNumber_H, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
    catch
        dates_H{1} = repmat(datetime([NaN NaN NaN]), size(dataArray_H{1}));
    end
end

startDate_H = dates_H{1}(1);
endDate_H = dates_H{1}(end);
allDates_H = (startDate_H:DateStep:endDate_H)';
DateNum_H = datenum(allDates_H);
[~,existingDates_H,~] = intersect(DateNum_H,data_dateNumber_H);
for i=1:length(allDates_H)
    DateLookup{i} = {allDates_H(i), datenum(allDates_H(i))};
end

start_date_index = 1043; % DateLookup{1043} is 01-Jan-2014 00:00 [735600]
end_date_index = start_date_index + (365*24); % DateLookup{9803} is 01-Jan-2015 00:00 [735965]

%% Split data into numeric and cell columns.
rawNumericColumns1_H = raw_data_H(:, [2,3,4,5,6,7,8]);
rawCellColumns1_H = raw_data_H(:, 1);

%% Replace non-numeric cells with NaN
R1_H = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns1_H); % Find non-numeric cells
rawNumericColumns1_H(R1_H) = {NaN}; % Replace non-numeric cells

%% Output Data Variables
GHI_CMP1_H = NaN(numel(allDates_H),1);
DNI_CHP1_H = NaN(numel(allDates_H),1);
DHI_CMP1_H = NaN(numel(allDates_H),1);
Air_Temp1_H = NaN(numel(allDates_H),1);
% BP1_H = NaN(numel(allDates_H),1);
% RH1_H = NaN(numel(allDates_H),1);
% Rain_Tot1_H = NaN(numel(allDates_H),1);

GHI_CMP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 1));
DNI_CHP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 2));
DHI_CMP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 3));
Air_Temp1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 4));
% BP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 5));
% RH1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 6));
% Rain_Tot1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 7));

%% Date Indices
start_month = allDates_H(start_date_index);
end_month = allDates_H(end_date_index);
DateDayIndex = datenum([start_month:days(1):end_month])';
DateMonthIndex = [735600 735631 735659 735690 735720 735751 735781 735812 735843 735873 735904 735934];
DateMonthLimit = [735600 735965];
DateMonthLabel = {'                  Jan','                  Feb','                  Mar','                  Apr',...
                  '                  May','                  Jun','                  Jul','                  Aug',...
                  '                  Sep','                  Oct','                  Nov','                  Dec'};

%% Calculations
Max_air_temp = max(Air_Temp1_H);
Min_air_temp = min(Air_Temp1_H);
Temperature_variation = abs(Max_air_temp-Min_air_temp);
Average_air_temp = mean(Air_Temp1_H,'omitnan');

disp(['Maximum air temperature: ',num2str(round(Max_air_temp,2)),'°C'])
disp(['Minimum air temperature: ',num2str(round(Min_air_temp,2)),'°C'])
disp(['Maximum annual variation in air temperature: ',num2str(round(Temperature_variation,2)),'°C'])
disp(['Average annual air temperature: ',num2str(round(Average_air_temp,2)),'°C'])
disp(' ')

% Calculated in plot_GRT_Annual_SolarPath_angles.m
Tilt_angle_summer = 55.9353; % (Noon on 21 June)
Tilt_angle_winter = 9.0829; % (Noon on 21 June)
Tilt_angle_optimal_mean = 32.5474;
Tilt_angle_optimal_weighted = 37.8243;

%% Max Irradiance Curve estimate
width1 = length(GHI_CMP1_H);
order1 = floor( log10(max(GHI_CMP1_H)));
value1 = ceil(max(GHI_CMP1_H)/(10^order1));
height1 = value1*10^order1;

t1 = [1:width1];
period1 = 12.5*366;
freq1 = pi/period1;
offset1 = 0.99;
max_height = max(GHI_CMP1_H);
% sine1 = 1.28/sqrt(2^5)*max_height*sin(t1*freq1 + offset1) + 850;

% j=1;
% for i=start_date_index:24:end_date_index
% Daily_peak_irradiance(j) = max(GHI_CMP1_H(i:i+23),[],'omitnan');
% j = j+1;
% end
% clear j;

variable_AngleVariables; % Load calculated values
TiltAngles = [Tilt_angle_optimal_weighted,Tilt_angle_optimal_mean,Tilt_angle_summer,Tilt_angle_winter,0.0];
Daily_max_irradiance = (0.96*max(GHI_CMP1_H)*cos(deg2rad(SunZenithAngle(:)*1.05)));

for i=1:numel(TiltAngles)
   irradiance_ratio(:,i) = transpose(cos(deg2rad(-Latitude + DeclinationAngle - TiltAngles(1,i)))...
       ./cos(deg2rad(-Latitude+DeclinationAngle)));
    Max_solar_power(:,i) = (Daily_max_irradiance(:).*irradiance_ratio(:,i))/1.7853; % normalising ratio
    Energy_tilt_totals(:,i) = cumtrapz(Max_solar_power(:,i));
end

[n m] = size(Energy_tilt_totals);
labels = {'Tilt angle (weighted)','Tilt angle (mean)',...
        'Tilt angle (summer)','Tilt angle (winter)','Horizonal Surface'};
disp('Total irradiance on tilted surface:')
for i=1:m
    disp([labels{i},' at ',num2str(TiltAngles(i)),...
        '° is ', num2str(Energy_tilt_totals(end,i)) , ' W/m^2' ])
end

%% Fit: 'Fourier Fit'. (temperature)
[xData, yData] = prepareCurveData( DateNum_H, Air_Temp1_H );

% Set up fittype and options.
ft = fittype( 'fourier3' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0 0 0 0 0.00630314526719285];

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                                  % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                         % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')            % replace with your system's monospaced font

%% Fig 1 - Global Horizontal Irradiance Average (Hourly)
if ismember(1,view) || ismember(1,output)
    
    fig_1 = figure('Position',...                            	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','on',...                                  % Give figure useful title
        'name','Global Horizontal Irradiance Average (Hourly)',...
        'Color','white');
    
    [n m] = size(irradiance_ratio);
    labels = {'Tilt angle (weighted)','Tilt angle (mean)',...
        'Tilt angle (summer)','Tilt angle (winter)','Horizonal Surface'};
    for i=1:m
        plot_num = strcat('p1_',num2str(i+1));
        variable.(plot_num) = plot(DateDayIndex,irradiance_ratio(:,i),...
        'DisplayName',labels{i},...
        'LineStyle','-',...
        'LineWidth',2);
        hold on
    end
    
    % Axes and labels
    ax1 = gca;
    set(ax1,...
        'Box','off',...
        'FontSize',14,...
        'YMinorTick','off',...
        'XMinorTick','off',...
        'XTick',DateMonthIndex,...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
        'Ylim',[0.6 1.8],...
        'FontName',fontName);
    ylabel(ax1,'Irradiance Ratios');
    xlabel(ax1,'Date \rightarrow');
    datetick(ax1,'x','dd mmm yyyy','keepticks','keeplimits')
    
    % Legend
    legend1 = legend(ax1,'show');
%         {'Maximum surface radiance','Tilt angle optimal (weighted)',...
%         'Tilt angle optimal (mean)','Tilt angle (summer)','Tilt angle (winter)'});
    set(legend1,...
        'Box','off',...
        'Position',[0.401567265013978 0.784686488453122 0.193618460538053 0.0666553310498579],...
        'EdgeColor',[1 1 1]);
%     legend1.PlotChildren = legend1.PlotChildren([1 2]);
    hold on

    % Adjust figure
    pos = get(ax1, 'Position');                                 % Current position
    pos(1) = 0.07;                                              % Shift Plot horizontally
    pos(2) = pos(2) - 0.02;                                     % Shift Plot vertically
    pos(3) = pos(3)*1.175;                                      % Scale plot horizontally
    pos(4) = pos(4)*1.05;                                        % Scale plot vertically
    set(ax1, 'Position', pos)
    hold off
    
    disp('Finished plotting Figure 1...')
end

%% Fig 2 - Average Air Temperature
if ismember(2,view) || ismember(1,output)
    fig_2 = figure('Position',...                            	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','on',...                                  % Give figure useful title
        'name','Average Air Temperature',...
        'Color','white');
    ax2 = gca;
    hold(ax2,'on');
    box(ax2,'off');
    
    p2_1 = plot(allDates_H,Air_Temp1_H,...
        'DisplayName','Measured Air Temp',...
        'Color',[0.933333337306976 0.764705896377563 0.505882382392883],...                         % [R G B Alpha]
        'LineStyle','-',...
        'LineWidth',1);
    hold on
    
	p2_2 = plot(fitresult);
    set(p2_2,...
        'DisplayName','Moving Average Air Temp',...
        'Color',[0.9 0.18 0.18 .6],...                 
        'LineStyle','-',...
        'LineWidth',2);
    hold on
    
    legend('hide');
    legend('off');
    
    p2_3 = refline(0,Average_air_temp);
    set(p2_3,'Color',[0.18 0.9 0.18 .6],... 
            'DisplayName','Mean Air Temp',...
            'LineStyle','-',...
            'LineWidth',2);
    hold on
    

    % Axes and labels
    set(ax2,'FontSize',14,...
        'YMinorTick','off',...
        'XMinorTick','off',...
        'XTick',DateMonthIndex,...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
        'YTick',sort([0:5:45 Average_air_temp]),...
        'Ylim',[0 45],...
        'FontName',fontName);
    ylabel('Temperature (celcius) \rightarrow')%,...
    xlabel('Date \rightarrow');
    
    % Ticks formatting
    %     datetick('x','dd mmm yyyy','keepticks','keeplimits')
    yt=get(ax2,'ytick');
    for k=1:numel(yt);
    yt2{k}=sprintf('%.2f°',yt(k));
    end
    set(ax2,'yticklabel',yt2);

    % Legend
    legend2 = legend(ax2,'show');
    set(legend2,'Position',[0.42519305019305 0.788253477588872 0.122104247104247 0.0772797527047914],...
        'Box','on',...
        'EdgeColor',[1 1 1]);
%     legend1.PlotChildren = legend1.PlotChildren([1 2]);
    hold on

    % Adjust figure
    pos_2 = get(ax2, 'Position');                            	% Current position
    pos_2(1) = 0.08;                                           	% Shift Plot horizontally
    pos_2(2) = pos_2(2) - 0.02;                                	% Shift Plot vertically
    pos_2(3) = pos_2(3)*1.16;                               	% Scale plot horizontally
    pos_2(4) = pos_2(4)*1.05;                                	% Scale plot vertically
    set(ax2, 'Position', pos_2)
    hold off
    
    disp('Finished plotting Figure 2...')
end

%% Fig 3 - Global Horizontal Irradiance Average (Hourly)
if ismember(3,view) || ismember(3,output)
    
    fig_3 = figure('Position',...                            	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','on',...                                  % Give figure useful title
        'name','Effect of tilt angle on irradiance collection',...
        'Color','white');

    [n m] = size(Max_solar_power);
    labels = {'Tilt angle (weighted)','Tilt angle (mean)',...
        'Tilt angle (summer)','Tilt angle (winter)','Horizonal Surface'};
    for i=1:m
        plot_num = strcat('p1_',num2str(i+1));
        variable.(plot_num) = plot(DateDayIndex,Max_solar_power(:,i),...
        'DisplayName',labels{i},...
        'LineStyle','-',...
        'LineWidth',2);
        hold on
    end
    
    % Axes and labels
    ax3 = gca;
    set(ax3,...
        'Box','off',...
        'FontSize',14,...
        'TickDir','out',...
        'YMinorTick','off',...
        'XMinorTick','off',...
        'XTick',DateMonthIndex,...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
        'Ylim',[0 1200],...
        'FontName',fontName);
    ylabel(ax3,'Solar Irradiance');
    xlabel(ax3,'Date \rightarrow');
    datetick(ax3,'x','dd mmm yyyy','keepticks','keeplimits')
    
    % Legend
    legend3 = legend(ax3,'show');
%         {'Maximum surface radiance','Tilt angle optimal (weighted)',...
%         'Tilt angle optimal (mean)','Tilt angle (summer)','Tilt angle (winter)'});
    set(legend3,...
        'Box','off',...
        'Position',[0.401567265013978 0.784686488453122 0.193618460538053 0.0666553310498579],...
        'EdgeColor',[1 1 1]);
%     legend3.PlotChildren = legend3.PlotChildren([1 2]);
    hold on

    % Adjust figure
    pos_3 = get(ax3, 'Position');                                 % Current position
    pos_3(1) = 0.07;                                              % Shift Plot horizontally
    pos_3(2) = pos_3(2) - 0.02;                                     % Shift Plot vertically
    pos_3(3) = pos_3(3)*1.175;                                      % Scale plot horizontally
    pos_3(4) = pos_3(4)*1.05;                                        % Scale plot vertically
    set(ax3, 'Position', pos_3)
    hold off
    
    disp('Finished plotting Figure 3...')
end

%% Output
if ismember(1,view) || ismember(1,output)
    set(fig_1, 'Visible', 'on');
    WinOnTop( fig_1, true );
end
if ismember(2,view) || ismember(2,output)
    set(fig_2, 'Visible', 'on');
    WinOnTop( fig_2, true );
end
if ismember(3,view) || ismember(3,output)
    set(fig_3, 'Visible', 'on');
    WinOnTop( fig_3, true );
end
if sum(view)<1
    disp('Image view disabled')
end
if sum(output)>0
	disp('Exporting images... please wait')
end
if ismember(1,output)
	export_fig ('../Report/images/Comparison_of_irradiance_ratios.eps',fig_1)
    disp('Exported Figure')
    close(fig_1);
end
if ismember(2,output)
	export_fig ('../Report/images/Air_Temp_Average.eps',fig_2)
    disp('Exported Figure')
    close(fig_2);
end
if ismember(3,output)
	export_fig ('../Report/images/Effect_of_tilt_angle_on_insolation.eps',fig_3)
    disp('Exported Figure')
    close(fig_3);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end
disp('Script complete')
