clc; clear all; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); warning off;

view    = [1 2];
output  = [];

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

DateMonthIndex = [735600 735631 735659 735690 735720 735751 735781 735812 735843 735873 735904 735934];
DateMonthLimit = [735600 735965];
DateMonthLabel = {'                  Jan','                  Feb','                  Mar','                  Apr',...
                  '                  May','                  Jun','                  Jul','                  Aug',...
                  '                  Sep','                  Oct','                  Nov','                  Dec'};

%% Curve estimate
width1 = length(GHI_CMP1_H);
order1 = floor( log10(max(GHI_CMP1_H)));
value1 = ceil(max(GHI_CMP1_H)/(10^order1));
height1 = value1*10^order1;

t1 = [1:width1];
period1 = 12.5*366;
freq1 = pi/period1;
offset1 = 0.99;
max_height = max(GHI_CMP1_H);
sine1 = 1.28/sqrt(2^5)*max_height*sin(t1*freq1 + offset1) + 730;


Average_air_temp = mean(Air_Temp1_H,'omitnan');

%% Fit: 'Fourier Fit'.
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

%% Draw plots
%% Fig 1 - Global Horizontal Irradiance Average (Hourly)
if ismember(1,view) || ismember(1,output)
    fig_1 = figure('Position',...                            	% draw figure
        [offset(1) offset(2) scr(3)*ratio scr(4)*ratio],...
        'Visible', 'off',...
        'numbertitle','on',...                                  % Give figure useful title
        'name','Global Horizontal Irradiance Average (Hourly)',...
        'Color','white');
    
    p1_1 = plot(allDates_H,GHI_CMP1_H,...                           
        'DisplayName','Measured GHI, Graaf-Reinet',...
        'Color',[0.729411764705882 0.831372549019608 0.956862745098039 0.6],...     % [R G B Alpha]
        'LineStyle','-',...
        'LineWidth',0.8,...
        'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],...
        'MarkerEdgeColor',[0 0.447058826684952 0.74117648601532],...
        'MarkerSize',2,...
        'Marker','o');
    hold on

	p1_2 = plot(allDates_H,sine1,...
         'DisplayName','Fitted Curve',...
        'Color',[0.18 0.18 0.18 .6],...                 
        'LineStyle','-',...
        'LineWidth',2);
    hold on

    % Axes and labels
    ax1 = gca;
    box(ax1,'on');
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
    legend1 = legend(ax1,'show');
    set(legend1,...
        'Location','North',...
        'Box','on',...
        'Position',[0.408861442020507 0.721338004606258 0.170925025013643 0.17304951684997],...
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
    box(ax2,'on');
    
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
    yt2{k}=sprintf('%.2f�',yt(k));
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

%% Output
if ismember(1,view)
    set(fig_1, 'Visible', 'on');
    WinOnTop( fig_1, true );
end
if ismember(2,view)
    set(fig_2, 'Visible', 'on');
    WinOnTop( fig_2, true );
end
if sum(view)<1
    disp('Image view disabled')
end
if sum(output)>0
	disp('Exporting images... please wait')
end
if ismember(1,output)
	export_fig ('../Report/images/GHI_Hourly_Measurements_Average.eps',fig_1)
    disp('Exported Figure')
    close(fig_1);
end
if ismember(2,output)
	export_fig ('../Report/images/Air_Temp_Average.eps',fig_2)
    disp('Exported Figure')
    close(fig_2);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end
disp('Script complete')
