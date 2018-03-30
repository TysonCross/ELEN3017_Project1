%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20130101_GRT_H.dat.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

clc; clear all; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); warning off;

view    = [1];
output  = [];

%% Initialize variables.
filename_H = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20130101_GRT_H.dat.txt';
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
BP1_H = NaN(numel(allDates_H),1);
RH1_H = NaN(numel(allDates_H),1);
Rain_Tot1_H = NaN(numel(allDates_H),1);

GHI_CMP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 1));
DNI_CHP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 2));
DHI_CMP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 3));
Air_Temp1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 4));
BP1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 5));
RH1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 6));
Rain_Tot1_H(existingDates_H) = cell2mat(rawNumericColumns1_H(:, 7));

DateMonthIndex = [735600 735631 735659 735690 735720 735751 735781 735812 735843 735873 735904 735934];
DateMonthLimit = [735600 735965];
DateMonthLabel = {'                  Jan','                  Feb','                  Mar','                  Apr',...
                  '                  May','                  Jun','                  Jul','                  Aug',...
                  '                  Sep','                  Oct','                  Nov','                  Dec'};

width1 = length(GHI_CMP1_H);
order1 = floor( log10(max(GHI_CMP1_H)));
value1 = ceil(max(GHI_CMP1_H)/(10^order1));
height1 = value1*10^order1;

t1 = [1:width1];
period1 = 365;
freq1 = 2*pi/period1;
offset1 = (5*30)*pi/365;
sine1 = 1/sqrt(2^3)*max(GHI_CMP1_H)*sin(t1*freq1 + offset1) + mean2(GHI_CMP1_H);

%% Fit: 'Fourier fit 1'.
[xData, yData] = prepareCurveData( DateNum_H, GHI_CMP1_H );

% Set up fittype and options.
ft = fittype( 'fourier1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Normalize = 'on';
opts.Robust = 'Bisquare';
opts.StartPoint = [0 0 0 1.84896230036409];

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fig_grt_avg = figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','off',...                            % Give figure useful title
        'name','Global Horizontal Irradiance Average (Hourly)',...
        'Color','white');
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')        % replace with your system's monospaced font

%% Draw plots
p1_1 = plot(allDates_H,GHI_CMP1_H,...                           
    'Color',[0.18 0.18 0.9 .6],...                          % [R G B Alpha]
	'LineStyle','-',...
	'LineWidth',1);
hold on

p2_1 = plot(fitresult1);
set(p2_1,...
    'Color',[0.9 0.18 0.18 .6],...                 
	'LineStyle',':',...
	'LineWidth',2);
hold on

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
title('GHI Graaf-Reinet',...
    'FontSize',14,...
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
pos(2) = pos(2) + 0.01;                                     % Shift Plot vertically
pos(3) = pos(3)*1.175;                                      % Scale plot horizontally
pos(4) = pos(4)*1.1;                                        % Scale plot vertically
set(ax1, 'Position', pos)
hold off

%% Output
if ismember(1,view)
    set(fig_grt_avg, 'Visible', 'on');
    WinOnTop( fig_grt_avg, true );
end
if sum(view)<0
    disp('Image view disabled')
end
if sum(output)>1
	disp('Exporting images... please wait')
end
if ismember(1,output)
	export_fig ('../Report/images/GHI_Hourly_Measurements_Average.eps',fig_grt_avg)
    disp('Exported Figure')
    close(fig1);
end
if sum(output)<0
	disp('Image export disabled')
else
	disp('All images exported')
end
disp('Script complete')
