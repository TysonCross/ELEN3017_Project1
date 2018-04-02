clc; clear all; set(0,'ShowHiddenHandles','on'); delete(get(0,'Children')); warning off;

view    = []; %[1]
output  = [];

%% Data for GRT 21st June/December (2014/2015)
Latitude = -32.48547;
Longitude = 24.58582;
Elevation = 660; % metres

[Date_2014,~,GHI_CMP11_Jun_2014,DNI_Jun_CHP1_2014,DHI_Jun_CMP11_2014,Air_Temp_Jun_2014,...
    BP_Jun_2014,RH_Jun_2014,Rain_Jun_Tot_2014,WS_Jun_2014,WD_Jun_2014,WD_SD_Jun_2014] = importfile('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/21_June_2014.dat.txt',5, 1444);

[Date_2015,~,GHI_CMP11_Jun_2015,DNI_CHP1_Jun_2015,DHI_CMP11_Jun_2015,Air_Temp_Jun_2015,...
    BP_Jun_2015,RH_Jun_2015,Rain_Tot_Jun_2015,WS_Jun_2015,WD_Jun_2015,WD_SD_Jun_2015] = importfile('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/21_June_2015.dat.txt',5, 1444);

[Date_Dec_2014,~,GHI_CMP11_Dec_2014,DNI_CHP1_Dec_2014,DHI_CMP11_Dec_2014,Air_Temp_Dec_2014,...
    BP_Dec_2014,RH_Dec_2014,Rain_Tot_Dec_2014,WS_Dec_2014,WD_Dec_2014,WD_SD_Dec_2014] = importfile('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/21_December_2014.dat.txt',5, 1444);

[Date_Dec_2015,~,GHI_CMP11_Dec_2015,DNI_CHP1_Dec_2015,DHI_CMP11_Dec_2015,Air_Temp_Dec_2015,...
    BP_Dec_2015,RH_Dec_2015,Rain_Tot_Dec_2015,WS_Dec_2015,WD_Dec_2015,WD_SD_Dec_2015] = importfile('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/21_December_2015.dat.txt',5, 1444);

GHI_Max_Dec = max(max(GHI_CMP11_Dec_2014));
GHI_Max_Jun = max(max(GHI_CMP11_Jun_2014));
GHI_Max_Avg = (GHI_Max_Dec+GHI_Max_Jun)/2;


Air_Temp_Max_Dec = max(max(Air_Temp_Dec_2014));
Air_Temp_Min_Dec = min(min(Air_Temp_Dec_2014));

Air_Temp_Max_Jun = max(max(Air_Temp_Jun_2014));
Air_Temp_Min_Jun = min(min(Air_Temp_Jun_2014));

Air_Temp_range_Max_Delta = abs(Air_Temp_Max_Dec-Air_Temp_Max_Jun);
Air_Temp_range_Absolute = abs(Air_Temp_Max_Dec-Air_Temp_Min_Jun);;

Solar_range_Max_Delta = abs(GHI_Max_Dec-GHI_Max_Jun);
Solar_range_Absolute = GHI_Max_Dec;

Total_insolation_Dec = sum(GHI_CMP11_Dec_2014)*10; % measured every 10 min
Total_insolation_Jun = sum(GHI_CMP11_Jun_2014)*10; % measured every 10 min

Average_insolation = (Total_insolation_Dec+Total_insolation_Jun)/2;
sun_hours_Dec = Total_insolation_Dec/GHI_Max_Dec;
sun_hours_Jun = Total_insolation_Jun/GHI_Max_Jun; 
Average_sun_hours = (sun_hours_Dec+sun_hours_Jun)/2;

%% Dates
[~,commonDates_Jun,~] = intersect(datenum(Date_2014),datenum(Date_2015));
assert(isempty(commonDates_Jun));

[~,commonDates_Dec,~] = intersect(datenum(Date_Dec_2014),datenum(Date_Dec_2015));
assert(isempty(commonDates_Dec));

try
    dateNumber = datenum(Date_2014);
    dates{1} = datetime(dateNumber, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dateNumber = datenum(Date_2014);
        dates{1} = datetime(dateNumber, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
    catch
        dates{1} = repmat(datetime([NaN NaN NaN]), size(Date_2014));
    end
end

try
    dateNumber_Dec = datenum(Date_Dec_2014);
    dates_Dec{1} = datetime(dateNumber_dec, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
catch
    try
        % Handle dates surrounded by quotes
        dateNumber_Dec = datenum(Date_Dec_2014);
        dates_Dec{1} = datetime(dateNumber_Dec, 'Format', 'dd-MMM-yyyy HH:mm', 'convertFrom','datenum');
    catch
        dates_Dec{1} = repmat(datetime([NaN NaN NaN]), size(Date_Dec_2014));
    end
end

DateStep = minutes(1);
startDate = dates{1}(1);
endDate = dates{1}(end);
allDates = (startDate:DateStep:endDate)';
allDatesNum = datenum(allDates);
XTickIndex = datenum([startDate:hours(2):endDate]);
XTickLimit = datenum([startDate endDate]);

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

%% Fig 1
if ismember(1,view) || ismember(1,output)
    % Create rectangle
    a1_1a = annotation('rectangle',[0.418980725502465 0.1015 0.213438735177866 0.809234507897933],...
        'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],...
        'LineWidth',1,...
        'LineStyle','--',...
        'FaceAlpha',0.5);
        hold on

    % Create rectangle
    a1_1b = annotation('rectangle',[0.467734674256414 0.1015 0.11699604743083 0.407797429357733],...
        'Color',[0.301960796117783 0.745098054409027 0.933333337306976],...
        'LineWidth',1,...
        'LineStyle','--',...
        'FaceAlpha',0.5);
        hold on
    
    a1_2a = annotation('rectangle',[0.417023166023166 0.100961538461538 0.21907722007722 0.00240384615384617],...
        'Color',[1 1 1],...
        'FaceColor',[1 1 1]);
    
    a2_1a = annotation('textbox',[0.638890703121068 0.881566645843613 0.2253861003861 0.0378670788253478],...
            'String',{'Equivalent sun-hours at peak irradiance'},...
            'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],...
            'LineStyle','none',...
            'FitBoxToText','on',...
            'BackgroundColor','white',...
            'FontSize',12,...
            'FontName',fontName);
    
    % Jun
    p1_1 = plot(allDates-0.01,GHI_CMP11_Jun_2014,...
        'DisplayName','21 June 2014',...
        'Color',[0 0.447058826684952 0.74117648601532],...
        'LineStyle','-',...
        'LineWidth',1.5);
    hold on
    
    p1_2 = plot(allDates-0.01,GHI_CMP11_Jun_2015,...
        'DisplayName','21 June 2015',...
        'Color',[0 0.749019622802734 0.749019622802734],...
        'LineStyle','-',...
        'LineWidth',1);
    hold on
    
    % Axes and labels
    ax1 = gca;
    box(ax1,'off');
    set(ax1,'FontSize',14,...
        'TickDir','out',...
        'YMinorTick','off',...
        'XMinorTick','off',...
        'XTick',XTickIndex,...
        'Xlim',XTickLimit,...
        'Ylim',[0 1200],...
        'FontSize',14,...
        'FontName',fontName);
    ylabel('Global Insolation \rightarrow')%,...
    xlabel('Hours \rightarrow');
    datetick('x','hh','keepticks','keeplimits')
        
    ax2 = axes;

    % Dec
    p1_3 = plot(ax2,allDates-0.01,GHI_CMP11_Dec_2014,...
        'DisplayName','21 December 2014',...
        'Color',[0.635294139385223 0.0784313753247261 0.184313729405403],...
        'LineStyle','-',...
        'LineWidth',2);
    hold on
    p1_4 = plot(ax2,allDates-0.01,GHI_CMP11_Dec_2015,...
        'DisplayName','21 December 2015',...
        'Color',[0.85 0.325 0.098 0.6],...
        'LineStyle','-',...
        'LineWidth',1);
    hold on
	
    % Axes and labels
    box(ax2,'off');
    set(ax2,'Visible','off',...
        'XTick',[],...
        'Xlim',XTickLimit,...
        'Ylim',[0 1200],...
        'FontSize',14,...
        'FontName',fontName)
    ylabel(ax2,'')%,...
    xlabel(ax2,'');
    

    % Legend
    legend1 = legend(ax1,'show');
    set(legend1,...
        'Box','off',...
        'Position',[0.474644163118797 0.513256678326775 0.0976878526914794 0.0612625524424556],...
        'EdgeColor',[1 1 1]);
    
    legend2 = legend(ax2,'show');
    set(legend2,...
        'Box','off',...
        'Position',[0.464642322499307 0.912743277082715 0.117966373152867 0.0608144152249769],...
        'EdgeColor',[1 1 1]);
%     legend1.PlotChildren = legend1.PlotChildren([1 7 6 5 4 3 2]);
    hold on

    % Adjust figure
    pos = get(ax1, 'Position');                                 % Current position
    pos(1) = 0.07;                                              % Shift Plot horizontally
    pos(2) = pos(2) - 0.01;                                     % Shift Plot vertically
    pos(3) = pos(3)*1.175;                                      % Scale plot horizontally
    pos(4) = pos(4)*1.05;                                     	% Scale plot vertically
    set([ax1 ax2], 'Position', pos)
    hold off
    
	disp('Finished plotting Figure 1...')
end

%% Output
disp(' ')
disp('--------------------------------')
disp('Winter solstice, 21 June 2014: ');
disp(['Total daily measured solar insolation: ', num2str(round(Total_insolation_Jun/1000,2)), ' kWhr/m^2'])
disp(['Maximum solar insolation peak at 12:00: ', num2str(round(GHI_Max_Jun/1000,2)), ' kW/m^2'])
disp(['Useful sun hours: ' num2str(round(sun_hours_Jun/1000,2)), 'h'])
disp(' ')
disp('Summer solstice, 21 December 2014: ');
disp(['Total daily measured solar insolation: ', num2str(round(Total_insolation_Dec/1000,2)), ' kWhr/m^2'])
disp(['Maximum solar insolation peak at 12:00: ', num2str(round(GHI_Max_Dec/1000,2)), ' kW/m^2'])
disp(['Useful sun hours: ' num2str(round(sun_hours_Dec/1000,2)), 'h'])
disp(' ')
disp('Average Day: ');
disp(['Average daily solar insolation for a day: ', num2str(round(Average_insolation/1000,2)), ' kW/m^2'])
disp(['Average solar insolation peak at 12:00: ', num2str(round(GHI_Max_Avg/1000,2)), ' kW/m^2'])
disp(['Useful sun hours: ' num2str(round(Average_sun_hours/1000,2)), 'h'])
disp('--------------------------------')
disp(' ')

% Write Variables to file
outfile = '/Users/Tyson/Documents/Academic/ELEN3017/Project/code/variable_EnergyTemp.m';
fid = fopen(outfile, 'wt');
fprintf(fid, '%s\n','% Calculated in B_Daily_Summer_Winter.m');

fprintf(fid, 'Total_insolation_Jun = %f;\n',Total_insolation_Jun);
fprintf(fid, 'Total_insolation_Dec = %f;\n',Total_insolation_Dec);
fprintf(fid, 'Average_insolation = %f;\n',Average_insolation);
fprintf(fid, 'GHI_Max_Jun = %f;\n',GHI_Max_Jun);
fprintf(fid, 'GHI_Max_Dec = %f;\n',GHI_Max_Dec);
fprintf(fid, 'Average_sun_hours = %f;\n',Average_sun_hours);

fprintf(fid, 'GHI_CMP11_Dec_2014 =  [');
fprintf(fid, '%f,',GHI_CMP11_Dec_2014(1:end-1));
fprintf(fid, '%f];\n',GHI_CMP11_Dec_2014(end));
fprintf(fid, 'GHI_Max_Dec = %f;\n',GHI_Max_Dec);
fprintf(fid, 'Air_Temp_Max_Dec = %f;\n',Air_Temp_Max_Dec);
fprintf(fid, 'Air_Temp_Min_Dec = %f;\n',Air_Temp_Min_Dec);

fprintf(fid, 'GHI_CMP11_Jun_2014 =  [');
fprintf(fid, '%f,',GHI_CMP11_Jun_2014(1:end-1));
fprintf(fid, '%f];\n',GHI_CMP11_Jun_2014(end));
fprintf(fid, 'GHI_Max_Jun = %f;\n',GHI_Max_Jun);
fprintf(fid, 'Air_Temp_Max_Jun = %f;\n',Air_Temp_Max_Jun);
fprintf(fid, 'Air_Temp_Min_Jun = %f;\n',Air_Temp_Min_Jun);

fprintf(fid, 'Air_Temp_range_Max_Delta = %f;\n',Air_Temp_range_Max_Delta);
fprintf(fid, 'Air_Temp_range_Absolute = %f;\n',Air_Temp_range_Absolute);
fprintf(fid, 'Total_insolation_Dec = %f;\n',Total_insolation_Dec);
fprintf(fid, 'Total_insolation_Jun = %f;\n',Total_insolation_Jun);
fprintf(fid, 'Solar_range_Max_Delta = %f;\n',Solar_range_Max_Delta);
fprintf(fid, 'Solar_range_Absolute = %f;\n',Solar_range_Absolute);

fclose(fid);
disp(['Variables written to file: ' , outfile]) 

% Images
if ismember(1,view) || ismember(1,output)
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
	export_fig ('../Report/images/Sun_SingleDay.eps',fig_grt)
    disp('Exported Figure')
    close(fig_grt);
end
if sum(output)<1
	disp('Image export disabled')
else
	disp('All images exported')
end
disp('Script complete')
