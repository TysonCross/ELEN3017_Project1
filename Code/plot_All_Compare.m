%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20170101_FRH_D.dat.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

clc
clear all

%% Sun equation
% syms t n
% t(n) = 9.873*sin( (4*pi / 365.242)*( n - 81 )) - 7.655*sin( (2*pi / 365.242)*( n - 1 ));
% n = [1:365];
% sun_eq = t(n);

%% Initialize variables.
filename = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20170101_FRH_D.dat.txt';
filename1 = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20130224_GRT_D.dat.txt';
delimiter = ',';
startRow = 5;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');
fileID1 = fopen(filename1,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
dataArray1 = textscan(fileID1, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);
fclose(fileID1);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
raw1 = repmat({''},length(dataArray1{1}),length(dataArray1)-1);

for col1=1:length(dataArray1)-1
    raw1(1:length(dataArray1{col1}),col1) = dataArray1{col1};
end
for col=1:length(dataArray1)-1
    raw1(1:length(dataArray1{col}),col) = dataArray1{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
numericData1 = NaN(size(dataArray1{1},1),size(dataArray1,2));

for col=[2,3,4,5,6,7,8]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

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
    dates1{1} = datetime(dateNumber1, 'Format', 'dd-MMM-yyyy', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dataArray1{1} = cellfun(@(x) x(2:end-1), dataArray1{1}, 'UniformOutput', false);
        dateNumber1 = datenum(dataArray1{1});
        dates1{1} = datetime(dateNumber1, 'Format', 'dd-MMM-yyyy', 'convertFrom','datenum');
    catch
        dates1{1} = repmat(datetime([NaN NaN NaN]), size(dataArray1{1}));
    end
end
try
    dateNumber = datenum(dataArray{1});
    dates{1} = datetime(dateNumber,'Format','dd-MMM-yyyy','convertFrom','datenum');
%     dates{1} = datetime(dataArray{1}, 'Format', 'yyyy-MMM-dd HH:mm:ss', 'InputFormat', 'yyyy-MMM-dd HH:mm:ss');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{1} = cellfun(@(x) x(1:end), dataArray{1}, 'UniformOutput', false);
        dateNumber = datenum(dataArray{1});
        dates{1} = datetime(dateNumber, 'Format', 'dd-MMM-yyyy', 'convertFrom','datenum');
    catch
        dates{1} = repmat(datetime([NaN NaN NaN]), size(dataArray{1}));
    end
end

anyBlankDates = cellfun(@isempty, dataArray{1});
anyInvalidDates = isnan(dates{1}.Hour) - anyBlankDates;
dates = dates(:,1);

anyBlankDates1 = cellfun(@isempty, dataArray1{1});
anyInvalidDates1 = isnan(dates1{1}.Hour) - anyBlankDates1;
dates1 = dates1(:,1);
%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [2,3,4,5,6,7,8]);
rawNumericColumns1 = raw1(:, [2,3,4,5,6,7,8]);
rawCellColumns1 = raw1(:, 1);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
R1 = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns1); % Find non-numeric cells
rawNumericColumns1(R1) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
Date = dates{:, 1};
GHI_CMP = cell2mat(rawNumericColumns(:, 1));
DNI_CHP = cell2mat(rawNumericColumns(:, 2));
DHI_CMP = cell2mat(rawNumericColumns(:, 3));
Air_Temp = cell2mat(rawNumericColumns(:, 4));
BP = cell2mat(rawNumericColumns(:, 5));
RH = cell2mat(rawNumericColumns(:, 6));
Rain_Tot = cell2mat(rawNumericColumns(:, 7));

Date1 = dates1{:, 1};
GHI_CMP1 = cell2mat(rawNumericColumns1(:, 1));
DNI_CHP1 = cell2mat(rawNumericColumns1(:, 2));
DHI_CMP1 = cell2mat(rawNumericColumns1(:, 3));
Air_Temp1 = cell2mat(rawNumericColumns1(:, 4));
BP1 = cell2mat(rawNumericColumns1(:, 5));
RH1 = cell2mat(rawNumericColumns1(:, 6));
Rain_Tot1 = cell2mat(rawNumericColumns1(:, 7));

GHI_CMP(isnan(GHI_CMP))=0;
DNI_CHP(isnan(DNI_CHP))=0;
DHI_CMP(isnan(DHI_CMP))=0;
Air_Temp1(isnan(Air_Temp))=0;
BP(isnan(BP))=0;
RH(isnan(RH))=0;
Rain_Tot(isnan(Rain_Tot))=0;

GHI_CMP1(isnan(GHI_CMP1))=0;
DNI_CHP1(isnan(DNI_CHP1))=0;
DHI_CMP1(isnan(DHI_CMP1))=0;
Air_Temp1(isnan(Air_Temp1))=0;
BP1(isnan(BP1))=0;
RH1(isnan(RH1))=0;
Rain_Tot1(isnan(Rain_Tot1))=0;

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).
DateNum = datenum(Date);
DateNum1 = datenum(Date1);

width = length(GHI_CMP);
order = floor( log10(max(GHI_CMP)));
value = ceil(max(GHI_CMP)/(10^order));
height = value*10^order;

width1 = length(GHI_CMP1);
order1 = floor( log10(max(GHI_CMP1)));
value1 = ceil(max(GHI_CMP1)/(10^order1));
height1 = value1*10^order1;

t1 = [1:width1];
period1 = 365;
freq1 = 2*pi/period1;
offset1 = (5*30)*pi/365;
sine1 = 1/sqrt(2^3)*max(GHI_CMP1)*sin(t1*freq1 + offset1) + mean2(GHI_CMP1);

GFA_long = 24.58582;
FHR_long = 26.8452;
lat_avg = (-32.78461 -32.48547)/2;
longitudinal_offset = departure(GFA_long, FHR_long, lat_avg, referenceEllipsoid('earth', 'nm'));
% total_offset=1095; % visual manipulatgion 
manual_offset = 28;
date_offset=1178; % days between 
total_offset = +date_offset-longitudinal_offset+manual_offset;

%% Fit: 'Fourier Fit'.
[xData, yData] = prepareCurveData( DateNum, GHI_CMP );

% Set up fittype and options.
ft = fittype( 'fourier1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.StartPoint = [0 0 0 0.0157868977567326];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

%% Fit: 'Fourier Fit'.
[xData1_1, yData_1] = prepareCurveData( DateNum1, GHI_CMP1 );

ft1 = fittype( 'fourier1' );
opts1 = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts1.Display = 'Off';
opts1.Robust = 'Bisquare';
opts1.StartPoint = [0 0 0 0.0157868977567326];

% Fit model to data.
[fitresult1, gof1] = fit( xData1_1+total_offset, yData_1, ft1, opts1 );


%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
fig1 =  figure('Position',...                               % draw figure
    [1 scr(4)*3/5 scr(3)*3/5 scr(4)*3/5]);
set(fig1,'numbertitle','off',...                            % Give figure useful title
    'name','Solar Irradiance Comparison',...
    'Color','white');
% set(fig1, 'MenuBar', 'none');                             % Make figure clean
% set(fig1, 'ToolBar', 'none');                             
% c = listfonts
fontName='CMU Serif';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')      

%% Plot
p1_1 = plot(Date,GHI_CMP,...                           
        'Color',[0.9 0.18 0.18 .4],...                 
        'LineStyle',':',...
        'LineWidth',1);
hold on
p2_1 = plot(Date1+total_offset,GHI_CMP1,...                           
        'Color',[0.18 0.18 0.9 .4],...                 
        'LineStyle',':',...
        'LineWidth',1);
hold on
% p3_1 = plot(n,sun_eq,...                           
%         'Color',[0.18 0.9 0.18 .4],...                 
%         'LineStyle','-',...
%         'LineWidth',1);
% hold on

% Plot fit with data.
h1_1 = plot( fitresult, xData, yData);
set(h1_1,'Color',[0.6 0.18 0.18 .6],...                 
        'LineStyle','-',...
        'LineWidth',2);                 

hold on
h2_1 = plot( fitresult1, xData1_1+total_offset, yData_1);
set(h2_1,'Color',[0.18 0.18 0.6 .6],...                 
        'LineStyle','-',...
        'LineWidth',2);                 
hold on

% Title
ax1 = gca;
title('Solar Irradiation approximation',...
    'FontSize',14,...
    'FontName',fontName);
% Axes and labels
width = length(GHI_CMP);
height = 500; %max(GHI_CMP1);
ylabel('Global Insolation \rightarrow',...
    'FontName',fontName,...
    'FontSize',14,...
    'Position', [-10*(width/height) 0.5*height]);
xlabel('Time \rightarrow',...
    'FontName',fontName,...
    'FontSize',14,...
    'Position', [0.5*width -10*(width/height)]);
set(ax1,'FontSize',14,...
    'XTickLabelRotation',45)
xlim(ax1,[Date(1) Date(end)]);
datetick('x','dd mmm yyyy','keepticks','keeplimits')
hold on
box(ax1,'off');
% hold(ax1,'on');


% Legend
% legend1 = legend({'Jacobi','Gauss-Seidel','SOR','Convergence tolerance'},...
%      'Position',[0.7    0.7    0.2    0.09],...
%      'Box','off');
 
axis(ax1,[DateNum(1) DateNum(1)+width+(width/100) 0 height]);
% % legend
legend1 = legend(...
     'Position',[0.0    0.88    0.1125    0.0403],...
     'Box','off');
hold off
% export (fix for missing CMU fonts in eps export)
% export_fig Report/letter_frequency.eps
