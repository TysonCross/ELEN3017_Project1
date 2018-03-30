clc; clear all; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); warning off;

view    = [1];
output  = [1];

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
filename1 = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20140101_GRT_H.dat.txt';
DateStep = hours(1);
% DateStep = days(1);
delimiter1 = ',';
startRow1 = 5;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
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
    Time{1,i} = str(3:end-3);
    raw_elevation(:,i) = [raw_sundata{:,j}]';
%     raw_azimuth(:,i)   = [raw_sundata{:,j+1}]';
    i = i+1;
end

%% Dates
raw_date = reshape([raw_date{:}],size(raw_date));
DateYear = raw_date;
% dateMonth = datetime(DateYear,'ConvertFrom','excel','Format','MMMM');
dateMonthDay = datetime(DateYear,'ConvertFrom','excel','Format','MMMM dd');
time = datetime(Time,'InputFormat','HH:mm','Format','HH:mm');
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
% DNI_CHP1 = NaN(numel(allDates),1);
% DHI_CMP1 = NaN(numel(allDates),1);
% Air_Temp1 = NaN(numel(allDates),1);
% BP1 = NaN(numel(allDates),1);
% RH1 = NaN(numel(allDates),1);
% Rain_Tot1 = NaN(numel(allDates),1);

GHI_CMP1(existingDates) = cell2mat(rawNumericColumns1(:, 1));
% DNI_CHP1(existingDates) = cell2mat(rawNumericColumns1(:, 2));
% DHI_CMP1(existingDates) = cell2mat(rawNumericColumns1(:, 3));
% Air_Temp1(existingDates) = cell2mat(rawNumericColumns1(:, 4));
% BP1(existingDates) = cell2mat(rawNumericColumns1(:, 5));
% RH1(existingDates) = cell2mat(rawNumericColumns1(:, 6));
% Rain_Tot1(existingDates) = cell2mat(rawNumericColumns1(:, 7));


%% Azimuth and Elevation
% i=1;
% for j=1:length(raw_elevation)
%     SunElevationYearMax(j,:) = max(raw_elevation(j,:));
%     SunAzimuthYear_min = deg2rad(min(raw_azimuth(j,:)));
%     SunAzimuthYearMin(j,:) = rad2deg(unwrap(SunAzimuthYear_min));
%     i = i + 1;
% end

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

% Theoretical Estimates (from solar plot)
DNI_estimate = 1000; % max(DNI_CHP1)*1.1;
GHI_Theoretical =  DNI_estimate*cos(deg2rad((SunZenithYear)));

width1 = length(GHI_CMP1);
order1 = floor( log10(max(GHI_CMP1)));
value1 = ceil(max(GHI_CMP1)/(10^order1));
height1 = value1*10^order1;

% t1 = [1:width1];
% period1 = 365;
% freq1 = 2*pi/period1;
% offset1 = (5*30)*pi/365;
% sine1 = 1/sqrt(2^3)*max(GHI_CMP1)*sin(t1*freq1 + offset1) + mean2(GHI_CMP1);

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fig_grt =  figure('Position',...                          	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'numbertitle','on',... 
        'Visible', 'off',...
        'name','Global Horizontal Irradiance (Hourly)',...
        'Color','white');
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')        % replace with your system's monospaced font

%% Draw plots
if ismember(1,view) || ismember(1,output)
    p1_1 = plot(allDates,GHI_CMP1,...
        'DisplayName','Measured GHI, Graaf-Reinet',...
        'Color',[0.729411764705882 0.831372549019608 0.956862745098039 0.6],...         % [R G B Alpha]
        'LineStyle','-',...
        'LineWidth',0.8,...
        'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],...
        'MarkerEdgeColor',[0 0.447058826684952 0.74117648601532],...
        'MarkerSize',2,...
        'Marker','o');
    hold on

    [n m] = size(GHI_Theoretical);
    GHI_theory_times = [1 4 5 6 7 8];
    k=1;
    for i=[1 4 5 6 7 8]
        GHI_labels(k)=strcat({'Theoretical GHI at'},{' '},TimeZenith(i));
        plot_num = strcat('p3_',num2str(i));
        variable.(plot_num) = plot(dateMonthDay,GHI_Theoretical(:,i),...
        'LineWidth',2);
        k=k+1;
        hold on
    end

    % Axes and labels
    ax1 = gca;
    box(ax1,'off');
    set(ax1,'FontSize',14,...
        'TickDir','out',...
        'YMinorTick','off',...
        'XMinorTick','off',...
        'XTick',DateMonthIndex,...
        'Xlim',DateMonthLimit,...
        'XTickLabel',DateMonthLabel,...
        'FontName',fontName);
    ylabel('Global Insolation \rightarrow')%,...
    xlabel('Date \rightarrow');
    % datetick('x','dd mmm yyyy','keepticks','keeplimits')

    % Legend
    legend1 = legend(ax1,'show','legend','Location','North',['Measured GHI',GHI_labels]);
    set(legend1,...
        'Box','off',...
        'Position',[0.408861442020507 0.721338004606258 0.170925025013643 0.17304951684997],...
        'EdgeColor',[1 1 1]);
    legend1.PlotChildren = legend1.PlotChildren([1 7 6 5 4 3 2]);
    hold on

    % Adjust figure
    pos = get(ax1, 'Position');                                 % Current position
    pos(1) = 0.07;                                              % Shift Plot horizontally
    pos(2) = pos(2) - 0.01;                                     % Shift Plot vertically
    pos(3) = pos(3)*1.175;                                      % Scale plot horizontally
    pos(4) = pos(4)*1.05;                                     	% Scale plot vertically
    set(ax1, 'Position', pos)
    hold off
    
	disp('Finished plotting Figure 1...')
end

%% Output
if ismember(1,view)
    set(fig_grt, 'Visible', 'on');
    WinOnTop( fig_grt, true );
end
if sum(view)<1
    disp('Image view disabled')
end
if sum(output)>0
	disp('Exporting images... please wait')
end
if ismember(1,output)
	export_fig ('../Report/images/GHI_Hourly_Measurements.eps',fig_grt)
    disp('Exported Figure')
    close(fig_grt);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end
disp('Script complete')
