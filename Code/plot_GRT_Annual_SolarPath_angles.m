clc; clear all; warning off; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'));

view    = [1 2 3 4]; % [1 2 3 4 5]
output  = [1 2 3 4];

%% Data for GRT 1/1/14-1/1/15
Latitude = -32.48547;
Longitude = 24.58582;
Elevation = 660; % metres

%% Import the data
[~, ~, raw] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2014_GRT.xlsx','AnnualSunPath_2014');
raw_sundata = raw(2:end,2:end);
raw_time = raw(1,2:end);
raw_date = raw(2:end,1);

%% Initialize variables.
filename1 = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20140101_GRT_D.dat.txt';
DateStep = days(1);
delimiter1 = ',';
startRow1 = 5;

%% Read columns of data as strings:
formatSpec = '%s%*s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID1 = fopen(filename1,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray1 = textscan(fileID1, formatSpec, 'Delimiter', delimiter1, 'HeaderLines' ,startRow1-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID1);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw1 = repmat({''},length(dataArray1{1}),length(dataArray1)-1);
for col1=1:length(dataArray1)-1
    raw1(1:length(dataArray1{col1}),col1) = dataArray1{col1};
end
numericData1 = NaN(size(dataArray1{1},1),size(dataArray1,2));

for col1=[2,3,4,5,6,7,8]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData1 = dataArray1{col1};
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
                raw1{row, col1} = numbers1{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using date
% format string.
try
    dateNumber1 = datenum(dataArray1{1});
    dates{1} = datetime(dateNumber1, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dataArray1{1} = cellfun(@(x) x(2:end-1), dataArray1{1}, 'UniformOutput', false);
        dateNumber1 = datenum(dataArray1{1});
        dates{1} = datetime(dateNumber1, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
    catch
        dates{1} = repmat(datetime([NaN NaN NaN]), size(dataArray1{1}));
    end
end

startDate = dates{1}(1);
endDate = dates{1}(end);
allDates = (startDate:DateStep:endDate)';
DateNum1 = datenum(allDates);
[~,existingDates,~] = intersect(DateNum1,dateNumber1);

%% Split data into numeric and cell columns.
rawNumericColumns1 = raw1(:, [2,3,4,5,6,7,8]);
rawCellColumns1 = raw1(:, 1);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),raw_sundata); % Find non-numeric cells
raw_sundata(R) = {NaN}; % Replace non-numeric cells

R1 = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns1); % Find non-numeric cells
rawNumericColumns1(R1) = {NaN}; % Replace non-numeric cells

%% Time
[n m] = size(raw_sundata);
i=1;
for j=1:2:m-1
    str = raw_time{1,j};
    time_day{1,i} = str(3:end-3);
    raw_elevation(:,i) = [raw_sundata{:,j}]';
    raw_azimuth(:,i)   = [raw_sundata{:,j+1}]';
    i = i+1;
end

%% Dates
raw_date = reshape([raw_date{:}],size(raw_date));
DateYear = raw_date;
dateMonth = datetime(DateYear,'ConvertFrom','excel','Format','MMMM');
dateMonthDay = datetime(DateYear,'ConvertFrom','excel','Format','MMMM dd');
time = datetime(time_day,'InputFormat','HH:mm','Format','HH:mm');
for i=1:length(dateMonthDay)
    DateLookup{i} = {dateMonthDay(i), datenum(dateMonthDay(i))};
end

DateMonthIndex = [735600 735631 735659 735690 735720 735751 735781 735812 735843 735873 735904 735934 735965];
DateMonthLimit = [735600 735965];
DateMonthLabel = {'                  Jan','                  Feb','                  Mar','                  Apr',...
                  '                  May','                  Jun','                  Jul','                  Aug',...
                  '                  Sep','                  Oct','                  Nov','                  Dec'};

%% Output Data Variables
GHI_CMP1 = NaN(numel(allDates),1);
DNI_CHP1 = NaN(numel(allDates),1);
DHI_CMP1 = NaN(numel(allDates),1);
Air_Temp1 = NaN(numel(allDates),1);
BP1 = NaN(numel(allDates),1);
RH1 = NaN(numel(allDates),1);
Rain_Tot1 = NaN(numel(allDates),1);

GHI_CMP1(existingDates) = cell2mat(rawNumericColumns1(:, 1));
DNI_CHP1(existingDates) = cell2mat(rawNumericColumns1(:, 2));
DHI_CMP1(existingDates) = cell2mat(rawNumericColumns1(:, 3));
Air_Temp1(existingDates) = cell2mat(rawNumericColumns1(:, 4));
BP1(existingDates) = cell2mat(rawNumericColumns1(:, 5));
RH1(existingDates) = cell2mat(rawNumericColumns1(:, 6));
Rain_Tot1(existingDates) = cell2mat(rawNumericColumns1(:, 7));

%% Azimuth and Elevation
i=1;
for j=1:length(raw_elevation)
    SunElevationYearMax(j,:) = max(raw_elevation(j,:));
    SunAzimuthYear_min = deg2rad(min(raw_azimuth(j,:)));
    SunAzimuthYearMin(j,:) = rad2deg(unwrap(SunAzimuthYear_min));
    i = i + 1;
end

%% Zenith
i=1;
for j=sort([5 6 7 8 9 10 11 12])  % from 6am to 12pm
    TimeZenith{1,i} = time_day{1,(j*6)+1};
    SunZenithYear(:,i) = raw_elevation(:,(j*6));    % Time columns in increments of 10 min
	i = i + 1;
end
R1 = arrayfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),SunZenithYear); % Find non-numeric cells
SunZenithYear(R1) = (0); % Replace non-numeric cells
SunZenithYear = 90 - SunZenithYear;

%% Theoretical Estimates (from solar plot)
DNI_estimate = 1000; %max(DNI_CHP1)*1.1;
GHI_Theoretical =  DNI_estimate*cos(deg2rad((SunZenithYear)));

width1 = length(GHI_CMP1);
order1 = floor( log10(max(GHI_CMP1)));
value1 = ceil(max(GHI_CMP1)/(10^order1));
height1 = value1*10^order1;

t1 = [1:width1];
period1 = 365;
freq1 = 2*pi/period1;
offset1 = (5*30)*pi/365;
sine1 = 1/sqrt(2^3)*max(GHI_CMP1)*sin(t1*freq1 + offset1) + mean2(GHI_CMP1);

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

%% Equation of Solar Time
% syms delta_time n;
% delta_time(n) = 9.873*sin( (4*pi / 365.242) * ( n - 81 )) - 7.655*sin( (2*pi / 365.242)* ( n - 1 ));
days = [1:366];
% equation_time = delta_time(days);

%% Monthly Totals
for i=1:numel(DateMonthIndex)-1
    offset_index = DateMonthIndex(1);
    index = [DateMonthIndex(i)-offset_index+1:DateMonthIndex(i+1)-offset_index];
    GHI_Monthly(i) = sum(GHI_CMP1(index),'omitnan');
    DNI_Monthly(i) = sum(DNI_CHP1(index),'omitnan');
    DHI_Monthly(i) = sum(DHI_CMP1(index),'omitnan');
end

GHI_Total = sum(GHI_CMP1(1:end-1),'omitnan');
GHI_Monthly_Total = sum(GHI_Monthly,'omitnan');
DNI_Total = sum(DNI_CHP1(1:end-1),'omitnan');
DNI_Monthly_Total = sum(DNI_Monthly,'omitnan');
DHI_Total = sum(DHI_CMP1(1:end-1),'omitnan');
DHI_Monthly_Total = sum(DHI_Monthly,'omitnan');

tol = 1.0e-06;
assert( (GHI_Total - GHI_Monthly_Total ) ./ GHI_Total .*100 < tol );
assert( (DNI_Total - DNI_Monthly_Total ) ./ DNI_Total .*100 < tol );
assert( (DHI_Total - DHI_Monthly_Total ) ./ DHI_Total .*100 < tol );

%% Tilt Angle (and output to display)

% Weighting
for i=1:12
    GHI_Weighting(i) = GHI_Monthly(i)/GHI_Total;
end
assert(sum(GHI_Weighting,'omitnan') - 1.0 < tol);

date_days = [1:366];
d_angle = degtorad(360./365.*date_days + 284);
DeclinationAngle = -23.45 * sin(d_angle);
TiltOptimal = -(Latitude-DeclinationAngle);
TiltAverage = mean(TiltOptimal);

for i=1:numel(DateMonthIndex)-1
    offset_index = DateMonthIndex(1);
    index = [DateMonthIndex(i)-offset_index+1:DateMonthIndex(i+1)-offset_index];
    DeclinationAngleMonthlyAverage(i) = mean(DeclinationAngle(index),'omitnan');
end

TiltAverageWeighted = 0;
for i=1:12
    mult = -(Latitude-DeclinationAngleMonthlyAverage(i)).*GHI_Weighting(i);
    TiltAverageWeighted = TiltAverageWeighted + mult;
end

% output
Max_tilt_angle = max(TiltOptimal);
Min_tilt_angle = min(TiltOptimal);
Tilt_variation = abs(Max_tilt_angle-Min_tilt_angle);
disp(['Maximum optimal tilt angle: ',num2str(round(Max_tilt_angle,2)),'°'])
disp(['Mimimum optimal tilt angle: ',num2str(round(Min_tilt_angle,2)),'°'])
disp(['Annual tilt variation: ',num2str(round(Tilt_variation,2)),'°'])
disp(['Optimal tilt angle (mean): ',num2str(round(TiltAverage,2)),'°'])
disp(['Optimal tilt angle (weighted): ',num2str(round(TiltAverageWeighted,2)),'°'])
disp(' ')
disp('---------------------')

%% Clear temporary variables
clearvars raw_sundata raw_azimuth raw_elevation raw_time raw_date R i j k str;
clearvars SunElevationDay_temp SunAzimuthDay_temp;
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr;
clearvars result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')        % replace with your system's monospaced font

%% Fig1 - Solar Altitude Angle (Daily)
if ismember(1,view) || ismember(1,output)
    fig1 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                            % Give figure useful title
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
    a1_1 = annotation('textbox',[0.469897034322266 0.892396267907816 0.0898080639902191 0.037854581810931],...
            'String',{'21 December'},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);
    a1_2 = annotation('textbox',[0.453965678107422 0.657494568470321 0.130366544501931 0.037854581810931],...
            'String',{'21 March/September'},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);hold off
    a1_3 = annotation('textbox',[0.485897034322266 0.427137954004702 0.0613205598212787 0.037854581810931],...
            'String',{'21 June'},...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);

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

%% Fig2 - Solar Azimith Angle
if ismember(2,view) || ismember(2,output)
    fig2 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                            % Give figure useful title
            'name','Solar Azimith Angle',...
            'Color','white');
    % Plot
    
    [n m] = size(SunAzimuthDay);
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
        'XTick',datenum([time(1)+hours(4):hours(1):time(end)-hours(3)]),...
        'Xlim',datenum([time(1)+hours(4) time(end)-hours(3)]),...
        'XTickLabel',datestr([time(1)+hours(4):hours(3):time(end)-hours(3)]),...
        'YTick',[-180:30:180],...
        'Ylim',[-180 180]);
        datetick('x','hh:00','keeplimits')

        %'XTick',[737149.125:0.125:737149.875]
        %'Xlim',[737149.125 737149.875]
        %'XTickLabel',{'03:00','06:00','09:00','12:00','15:00','18:00','21:00'}

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
    'Position',[0.703622249455684 0.818412474350363 0.154440154440154 0.0772542485937369],...
    'EdgeColor',[1 1 1],...
  	'Box','off');
    legend2.PlotChildren = legend2.PlotChildren([1,3,2]);

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

%% Fig3 - Annual Solar Azimuth (Minimum)
if ismember(3,view) || ismember(3,output)
    fig3 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                            % Give figure useful title
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
        'XTick',DateMonthIndex(1:end-1),...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
        'YTick',[0:5:20],...
        'Ylim',[0 20]);
    ylabel(ax3,...
        'Minimim Solar Azimuth Angle (deg)');
    xlabel(ax3,...
        'Date \rightarrow');

    % Adjust Figure 3
    pos_3 = get(ax3, 'Position');                              	% Current position
    pos_3(1) = 0.06;                                          	% Shift Plot horizontally
    pos_3(2) = pos_3(2) - 0.02;                                	% Shift Plot vertically
    pos_3(3) = pos_3(3)*1.17;                                  	% Scale plot horizontally
    pos_3(4) = pos_3(4)*1.05;                                  	% Scale plot vertically
    set(ax3, 'Position', pos_3);
    hold off

    disp('Finished plotting Figure 3...')
end

%% Fig4 - Annual Zenith Angle
if ismember(4,view) || ismember(4,output)
    fig4 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                            % Give figure useful title
            'name','Annual Zenith Angle',...
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
        'Box','off',...
        'XMinorTick','off',...
        'YMinorTick','on',...
        'XGrid','off',...
        'XTick',DateMonthIndex(1:end-1),...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
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

    pos_4 = get(ax4, 'Position');                              	% Current position
    pos_4(1) = 0.06;                                          	% Shift Plot horizontally
    pos_4(2) = pos_4(2) - 0.025;                               	% Shift Plot vertically
    pos_4(3) = pos_4(3)*1.175;                               	% Scale plot horizontally
	pos_4(4) = pos_4(4)*1.09;                                  	% Scale Plot vertically

    set(ax4, 'Position', pos_4)
    hold off

    disp('Finished plotting Figure 4...')
end

%% Fig5 - Tilt Angle
if ismember(5,view) || ismember(5,output)
    fig5 =  figure('Position',...                               % draw figure
            [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
            'Visible', 'off',...
            'numbertitle','on',...                            % Give figure useful title
            'name','Tilt Angle',...
            'Color','white');

    % plot
    p5_1 = plot(dateMonthDay,TiltOptimal,...
        'Color',[0.9 0.18 0.18 .6],...                          % [R G B Alpha]
        'LineStyle','-',...
        'LineWidth',2);
    hold on
    p5_2 = refline(0,TiltAverage);
    set(p5_2,'Color',[0.18 0.18 0.9 .6],...                 
            'LineStyle','-',...
            'LineWidth',2);
    hold on
    p5_2 = refline(0,TiltAverageWeighted);
    set(p5_2,'Color',[0.18 0.9 0.18 .6],...                 
            'LineStyle','-',...
            'LineWidth',2);
    hold on
    % Axis
    ax5 = gca;
    set(ax5,...
        'FontSize',14,...
        'FontName',fontName,...
        'Box','off',...
        'XMinorTick','off',...
        'YMinorTick','on',...
        'XGrid','off',...
        'XTick',DateMonthIndex(1:end-1),...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
        'YTick',sort([0:6:60 TiltAverage TiltAverageWeighted]),...
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
        {'Optimal Tilt Angle','Average Tilt Angle','Weighted Average Tilt Angle'},...
        'Position',[0.675287904014671 0.255631189606246 0.19216994337692 0.0782],...
        'Location','best',...
        'EdgeColor',[1 1 1],...
        'Box','off');

    pos_5 = get(ax5, 'Position');                                 % Current position
    pos_5(1) = 0.08;                                              % Shift Plot horizontally
    pos_5(2) = pos_5(2) - 0.025;                                   % Shift Plot vertically
    pos_5(3) = pos_5(3)*1.15;                                     % Scale plot vertically
	pos_5(4) = pos_5(4)*1.1;                                      % Scale plot horizontally
    set(ax5, 'Position', pos_5)
    hold off

    disp('Finished plotting Figure 5...')
end

%% Output
if ismember(1,view) || ismember(1,output)
    set(fig1, 'Visible', 'on');
    WinOnTop( fig1, true );
end
if ismember(2,view) || ismember(2,output)
    set(fig2, 'Visible', 'on');
    WinOnTop( fig2, true );
end
if ismember(3,view) || ismember(3,output)
    set(fig3, 'Visible', 'on');
    WinOnTop( fig3, true );
end
if ismember(4,view) || ismember(4,output)
    set(fig4, 'Visible', 'on');
    WinOnTop( fig4, true );
end
if ismember(5,view) || ismember(5,output)
    set(fig5, 'Visible', 'on');
    WinOnTop( fig5, true );
end
if sum(view)<1
    disp('Image view disabled')
end
if sum(output)>0
	disp('Exporting images... please wait')
end

if ismember(5,output)
	export_fig ('../Report/images/Optimal_Tilt_Angle.eps',fig5)
    disp('Exported Fig5')
    close(fig5);
end
if ismember(4,output)
	export_fig ('../Report/images/Solar_Zenith_Annual.eps',fig4)
    disp('Exported Fig4')
    close(fig4);
end
if ismember(3,output)
	export_fig ('../Report/images/Solar_Azimith_Min_Annual.eps',fig3)
    disp('Exported Fig3')
    close(fig3);
end
if ismember(2,output)
	export_fig ('../Report/images/Solar_Azimith_Angle_Daily.eps',fig2)
    disp('Exported Fig2')
    close(fig2);
end
if ismember(1,output)
	export_fig ('../Report/images/Solar_Altitude_Daily.eps',fig1)
    disp('Exported Fig1')
    close(fig1);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end
disp('Script complete')
