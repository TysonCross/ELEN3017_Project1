% GRT Expected Power output & Average Air Temperature (Hourly) 
clc; clear all; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); warning off;

view    = [3]; % [2 3]
output  = [3];

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
Average_air_temp = mean(Air_Temp1_H,'omitnan');
Max_air_temp = max(Air_Temp1_H)*(1-0.04);
Min_air_temp = min(Air_Temp1_H)*(1-0.15);
Temperature_variation = abs(Max_air_temp-Min_air_temp);

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

variable_AnnualGHI;
%{
    The following variables are loaded:
    GHI_CMP1
%}

variable_EnergyTemp; % load energy and temperature values for simulation
%{
    The following variables are loaded:

	Total_insolation_Jun
	Total_insolation_Dec
	Average_insolation
	GHI_Max_Jun
	GHI_Max_Dec
	Average_sun_hours

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

%% Tilt Angles on irradiance

TiltAngles = [Tilt_angle_optimal_weighted,Tilt_angle_optimal_mean,Tilt_angle_min,Tilt_angle_max,0.0];
TiltLabels = {'Tilt angle (weighted)','Tilt angle (mean)',...
        'Tilt angle (min)','Tilt angle (max)','No tilt (horizonal)'};
Daily_max_irradiance = (0.95*max(GHI_CMP1_H)*cos(deg2rad(SunZenithAngle(:)*1.05)));
Daily_max_irradiance = max(GHI_CMP1_H)*cos(deg2rad(SunZenithAngle(:)));

for i=1:numel(TiltAngles)
   irradiance_ratio(:,i) = transpose(cos(deg2rad(-Latitude + DeclinationAngle - TiltAngles(1,i)))...
       ./cos(deg2rad(-Latitude+DeclinationAngle)));
    b_angle(:,i) = deg2rad(90-SunZenithAngle(:) + TiltAngles(i));
    Max_solar_energy(:,i) = Daily_max_irradiance(:).* sin(b_angle(:,i));
    Energy_tilt_totals(:,i) = cumtrapz(Max_solar_energy(:,i)*4.33);
end

Total_measured_annual_solar_energy = max(sum(GHI_CMP1_H,'omitnan'));

%% Fit: 'Fourier Fit'. (temperature)
[xData, yData] = prepareCurveData( DateNum_H, Air_Temp1_H );

% Set up fittype and options.
ft = fittype( 'fourier3' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
excludedPoints = excludedata( xData, yData, 'Indices', [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 52 53 54 55 56 57 58 59 60 61 62 63 64 65 79 80 81 82 83 84 85 86 87 88 109 110 111 126 127 128 129 130 131 132 133 134 135 136 137 152 153 154 155 156 157 158 159 160 161 180 181 182 183 184 185 203 204 205 206 207 224 225 226 227 228 229 230 231 232 233 247 248 249 250 251 252 253 254 255 256 270 271 272 273 274 275 276 277 278 279 280 281 282 297 298 299 300 301 302 303 304 305 306 397 398 9744 9763 9764 9765 9766 9767 9768 9769 9983 9984 9985 9986 9987 9988 9989 10026 10030 10031 10032 10033 10034 10035 10036 10037 10052 10053 10054 10056 10057 10058 10059 10060 10061 10062 10063 10075 10076 10077 10078 10080 10081 10082 10086 10087 10088 10099 10100 10101 10102 10103 10104 10105 10106 10108 10109 10110 10111 10127 10128 10129 10130 10132 10133 10146 10147 10148 10149 10165 10166 10167 10168 10169 10170 10171 10172 10173 10174 10211 10212 10213 10214 10216 10217 10218 10219 10221 10223 10237 10238 10239 10241 10242 10245 10246 10343 10344 10352 10353 10354 10356 10357 10358 10359 10360 10374 10375 10377 10378 10379 10380 10381 10382 10383 10426 10427 10428 10429 10430 10432 10433 10434 10435 10436 10455 10456 10457 10458 10459 10479 10480 10481 10482 10497 10498 10589 10590 10591 10592 10610 10611 10612 10613 10614 10615 10636 10637 10638 10639 10640 10679 10680 10681 10685 10686 10687 10688 10689 10690 10707 10708 10709 10710 10727 10728 10729 10735 10780 10781 10793 10794 10795 10796 10797 10798 10799 10800 10801 10802 10803 10804 10805 10806 10807 10808 10818 10819 10820 10821 10822 10823 10824 10825 10826 10827 10828 10844 10845 10846 10849 10850 10851 10867 10868 10869 10870 10871 10872 10873 10874 10875 10890 10891 10892 10893 10894 10895 10896 10897 10898 10899 10900 10911 10912 10913 10914 10915 10916 10917 10918 10919 10921 10922 10923 10924 10925 10926 10937 10938 10939 10940 10941 10945 10946 10947 10948 10950 10951 10963 10964 10965 10966 10967 10968 10969 10970 10971 10972 10973 10987 10988 10989 10990 10991 10992 10993 10994 10995 10996 10997 10998] );
opts.Display = 'Off';
% opts.StartPoint = [0 0 0 0 0 0 0 0.00630314526719285];
opts.StartPoint = [0 0 0 0 0 0 0 0.000267506186443273];
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData+10, yData, ft, opts );

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

%% Fig 1 - Comparison of Irradiance Ratios
if ismember(1,view) || ismember(1,output)
    
    fig_1 = figure('Position',...                            	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','on',...                                  % Give figure useful title
        'name','Comparison of Irradiance Ratios',...
        'Color','white');
    
    [n m] = size(irradiance_ratio);
    for i=1:m
        plot_num = strcat('p1_',num2str(i+1));
        variable.(plot_num) = plot(DateDayIndex,irradiance_ratio(:,i),...
        'DisplayName',TiltLabels{i},...
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
%     datetick(ax1,'x','dd mmm yyyy','keepticks','keeplimits')
    
    % Legend
    legend1 = legend(ax1,'show');
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
    
	p2_2 = plot(fitresult, 'predobs');
    set(p2_2,...
        'DisplayName','95% Prediction bounds',...
        'Color',[0.9 0.18 0.18 .6],...                 
        'LineStyle',':',...
        'LineWidth',1);
    hold on
    
    p2_3 = plot(fitresult);
    set(p2_3,...
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
    legend2.PlotChildren = legend2.PlotChildren([1 6 5 2]);
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

%% Fig 3 - Effect of tilt angle on irradiance collection
if ismember(3,view) || ismember(3,output)
    
    fig_3 = figure('Position',...                            	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','on',...                                  % Give figure useful title
        'name','Effect of tilt angle on irradiance collection',...
        'Color','white');
    
    [n m] = size(Max_solar_energy);
    for i=1:m
        plot_num = strcat('p2_',num2str(i+1));
        variable.(plot_num) = plot(DateDayIndex,Max_solar_energy(:,i),...
        'DisplayName',TiltLabels{i},...
        'LineStyle','-',...
        'LineWidth',1.5);
        hold on
    end
    
%     p2_1 = plot(DateDayIndex,Daily_max_irradiance,...
%         'DisplayName','Maximum surface radiance',...
%         'Color',[0.9 0.18 0.18 1],...                 
%         'LineStyle','--',...
%         'LineWidth',1.5);
%     hold on
    
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
    ylabel(ax3,'Solar Irradiance (W/m^2) \rightarrow');
    xlabel(ax3,'Date \rightarrow');
%     datetick(ax3,'x','dd mmm yyyy','keepticks','keeplimits')
    
    % Legend
    legend3 = legend(ax3,'show');
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
disp(' ')
disp('-------------------------')
disp(['Maximum air temperature: ',num2str(round(Max_air_temp,2)),'°C'])
disp(['Minimum air temperature: ',num2str(round(Min_air_temp,2)),'°C'])
disp(['Maximum annual variation in air temperature: ',num2str(round(Temperature_variation,2)),'°C'])
disp(['Average annual air temperature: ',num2str(round(Average_air_temp,2)),'°C'])
disp(' ')

disp(['Annual measured solar irradiance total: ',...
    num2str(round(Total_measured_annual_solar_energy/1000,2)),' kW/m^2'])
disp(' ')
[n m] = size(Energy_tilt_totals);
disp('Annual irradiance totals for tilted surfaces')
for i=1:m
    disp(['   ',TiltLabels{i},' at ',num2str(TiltAngles(i)),...
        '° is ', num2str(Energy_tilt_totals(end,i)/1000) , ' kW/m^2' ])
end
disp(' ')
disp('-------------------------')

% Images
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
