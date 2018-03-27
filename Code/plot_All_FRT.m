%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20170101_FRH_D.dat.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

clc
clear all

%% Initialize variables.
filename = '/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/20170101_FRH_D.dat.txt';
delimiter = ',';
startRow = 5;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

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

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [2,3,4,5,6,7,8]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
Date = dates{:, 1};
GHI_CMP = cell2mat(rawNumericColumns(:, 1));
DNI_CHP = cell2mat(rawNumericColumns(:, 2));
DHI_CMP = cell2mat(rawNumericColumns(:, 3));
Air_Temp = cell2mat(rawNumericColumns(:, 4));
BP = cell2mat(rawNumericColumns(:, 5));
RH = cell2mat(rawNumericColumns(:, 6));
Rain_Tot = cell2mat(rawNumericColumns(:, 7));

GHI_CMP(isnan(GHI_CMP))=0;
DNI_CHP(isnan(DNI_CHP))=0;
DHI_CMP(isnan(DHI_CMP))=0;
Air_Temp1(isnan(Air_Temp))=0;
BP(isnan(BP))=0;
RH(isnan(RH))=0;
Rain_Tot(isnan(Rain_Tot))=0;

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).
DateNum = datenum(Date);

width = length(GHI_CMP);
order = floor( log10(max(GHI_CMP)));
value = ceil(max(GHI_CMP)/(10^order));
height = value*10^order;

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

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns R;

%% Display setting and output setup
scr = get(groot,'ScreenSize');                              % screen resolution
fig1 =  figure('Position',...                               % draw figure
    [1 scr(4)*3/5 scr(3)*3/5 scr(4)*3/5]);
set(fig1,'numbertitle','off',...                            % Give figure useful title
    'name','GHI Alice, Fort Hare',...
    'Color','white');
% set(fig1, 'MenuBar', 'none');                             % Make figure clean
% set(fig1, 'ToolBar', 'none');                             
% c = listfonts
fontName='CMU Serif';
set(0,'defaultAxesFontName', fontName);                     % Make fonts pretty
set(0,'defaultTextFontName', fontName);
set(groot,'FixedWidthFontName', 'ElroNet Monospace')      

%% Plot
% Top
p1_1 = plot(Date,GHI_CMP,...                           
        'Color',[0.18 0.18 0.9 .6],...                 
        'LineStyle','-',...
        'LineWidth',2);
hold on
% Plot fit with data.
h1_1 = plot( fitresult, xData, yData);
hold on
% Top title
ax1 = gca;
title('GHI Fort Hare, Alice',...
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
datetick('x','dd mmm yyyy','keepticks','keeplimits')

% axis(ax1,[DateNum(1) DateNum(1)+width+(width/100) 0 height]);
% % legend
 set(legend1,...
     'Position',[0.0    0.88    0.1125    0.0403],...
     'Box','off');
hold off
% export (fix for missing CMU fonts in eps export)
% export_fig Report/letter_frequency.eps
