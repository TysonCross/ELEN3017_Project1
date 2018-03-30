%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20140101_GRT_D.dat.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

clc; clear all; warning off;

%% Initialize variables.
filename1 = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20140101_GRT_D.dat.txt';
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
    dates{1} = datetime(dateNumber1, 'Format', 'dd-MMM-yyyy', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dataArray1{1} = cellfun(@(x) x(2:end-1), dataArray1{1}, 'UniformOutput', false);
        dateNumber1 = datenum(dataArray1{1});
        dates{1} = datetime(dateNumber1, 'Format', 'dd-MMM-yyyy', 'convertFrom','datenum');
    catch
        dates{1} = repmat(datetime([NaN NaN NaN]), size(dataArray1{1}));
    end
end

allDates = (dateNumber1(1):dateNumber1(end))';
[~,existingDates,~] = intersect(allDates,dateNumber1);

%% Split data into numeric and cell columns.
rawNumericColumns1 = raw1(:, [2,3,4,5,6,7,8]);
rawCellColumns1 = raw1(:, 1);


%% Replace non-numeric cells with NaN
R1 = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns1); % Find non-numeric cells
rawNumericColumns1(R1) = {NaN}; % Replace non-numeric cells


%% Allocate imported array to column variable names
% Date1 = dates{:, 1};
Date1 = datetime(allDates, 'Format', 'dd-MMM-yyyy', 'convertFrom','datenum');

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

% GHI_CMP1(isnan(GHI_CMP1))=0;
% DNI_CHP1(isnan(DNI_CHP1))=0;
% DHI_CMP1(isnan(DHI_CMP1))=0;
% Air_Temp1(isnan(Air_Temp1))=0;
% BP1(isnan(BP1))=0;
% RH1(isnan(RH1))=0;
% Rain_Tot1(isnan(Rain_Tot1))=0;

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).
DateNum1 = datenum(Date1);

DateMonthIndex = [735600 735631 735659 735690 735720 735751 735781 735812 735843 735873 735904 735934, 735965];
DateMonthLimit = [735600 735965];
DateMonthLabel = {'Jan', 'Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan'};

% Monthly Totals
for i=1:numel(DateMonthIndex)-1
    offset_index = DateMonthIndex(1);
    index = [DateMonthIndex(i)-offset_index+1:DateMonthIndex(i+1)-offset_index];
    GHI_Monthly(i) = sum(GHI_CMP1(index),'omitnan');
    DNI_Monthly(i) = sum(DNI_CHP1(index),'omitnan');
    DHI_Monthly(i) = sum(DHI_CMP1(index),'omitnan');
end

tol = 0.00001;
assert(...
(((sum(GHI_CMP1(1:end-1),'omitnan')-sum(GHI_Monthly,'omitnan') ) ./ sum(GHI_CMP1,'omitnan') *100) < tol ) &&...
(((sum(DNI_CHP1(1:end-1),'omitnan')-sum(DNI_Monthly,'omitnan') ) ./ sum(DNI_CHP1,'omitnan') *100) < tol ) &&...
(((sum(DHI_CMP1(1:end-1),'omitnan')-sum(DHI_Monthly,'omitnan') ) ./ sum(DHI_CMP1,'omitnan') *100) < tol ) );

% Maximums
% [GHI_Max,loc_GHI_Max] = findpeaks(GHI_CMP1);
% [DNI_Max,loc_DNI_Max] = findpeaks(DNI_CHP1);
% [DHI_Max,loc_DHI_Max] = findpeaks(DHI_CMP1);
% figx= figure;
% plot(loc_GHI_Max,GHI_Max)
% plot(loc_DNI_Max,DNI_Max)
% plot(loc_DHI_Max,DHI_Max)


width1 = length(GHI_CMP1);
order1 = floor( log10(max(GHI_CMP1)));
value1 = ceil(max(GHI_CMP1)/(10^order1));
height1 = value1*10^order1;

t1 = [1:width1];
period1 = 365;
freq1 = 2*pi/period1;
offset1 = (5*30)*pi/365;
sine1 = 1/sqrt(2^3)*max(GHI_CMP1)*sin(t1*freq1 + offset1) + mean2(GHI_CMP1);

%% Fit: 'Fourier Fit'.
[xData1, yData1] = prepareCurveData( DateNum1, GHI_CMP1 );

% Set up fittype and options.
ft1 = fittype( 'fourier1' );
opts1 = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts1.Display = 'Off';
opts1.Robust = 'Bisquare';
opts1.StartPoint = [0 0 0 0.0157868977567326];

% Fit model to data.
[fitresult1,~] = fit( xData1, yData1, ft1, opts1 );

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
phi = (1 + sqrt(5))/2;
ratio = phi/3;
offset = [ scr(3)/4 scr(4)/4]; 
fig1 =  figure('Position',...                               % draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio]);
set(fig1,'numbertitle','off',...                            % Give figure useful title
        'name','Global Horizontal Irradiance',...
        'Color','white');
fontName='Helvetica';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')        % replace with your system's monospaced font

% Draw plots
p1_1 = plot(Date1,GHI_CMP1,...                           
    'Color',[0.18 0.18 0.9 .6],...                          % [R G B Alpha]
	'LineStyle','-',...
	'LineWidth',1);
hold on
p1_2 = plot(fitresult1);
set(p1_2,...
    'Color',[0.9 0.18 0.18 .6],...                 
	'LineStyle',':',...
	'LineWidth',2);
hold on


% Axes and labels
ax1 = gca;
box(ax1,'off');
set(ax1,'FontSize',14,...
    'YMinorTick','off',...
    'XMinorTick','off',...
    'XTickLabelRotation',45,...
    'FontName',fontName);
title('GHI Graaf-Reinet',...
    'FontSize',14,...
    'FontName',fontName);
ylabel('Global Insolation \rightarrow')%,...
xlabel('Date \rightarrow');
datetick('x','dd mmm yyyy','keepticks','keeplimits')

% Legend
legend1 = legend({'Measured GHI','Average GHI'});
set(legend1,...
	'Location','best',...
	'Position',[0.428 0.793 0.118 0.053],...
	'Box','on');
hold off

% Adjust figure
pos = get(ax1, 'Position');                                 % Current position
pos(1) = 0.08;                                              % Shift Plot horizontally
pos(2) = pos(2) + 0.03;                                     % Shift Plot vertically
pos(3) = pos(3)*1.1;                                        % Scale plot vertically
set(ax1, 'Position', pos)
hold off

% export (fix for missing CMU fonts in eps export)
% export_fig Report/letter_frequency.eps
