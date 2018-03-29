
clc; clear all;
%% Import the data
[~, ~, raw_sundata] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017_1522312124298 10min.xlsx','SunEarthTools_AnnualSunPath_201');
raw_sundata = raw_sundata(2:end,2:end);

[~, ~, raw_time] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017_1522312124298 10min.xlsx','SunEarthTools_AnnualSunPath_201');
raw_time = raw_time(1,2:end);

[~, ~, raw_date] = xlsread('/Users/Tyson/Documents/Academic/ELEN3017/Project/Data/SunEarthTools_AnnualSunPath_2017_1522312124298 10min.xlsx','SunEarthTools_AnnualSunPath_201');
raw_date = raw_date(2:end,1);


%% Prepare and split data
% raw_time(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw_time)) = {''};
R = cellfun(@(x) (~isnumeric(x) && ~islogical(x)) || isnan(x),raw_sundata); % Find non-numeric cells
raw_sundata(R) = {NaN}; % Replace non-numeric cells

[n m] = size(raw_sundata);
i=1;
for j=1:2:m-1
    str = raw_time{1,j};
    Time{1,i} = str(3:end);
    raw_elevation(:,i) = [raw_sundata{:,j}]';
    raw_azimuth(:,i)   = [raw_sundata{:,j+1}]';
    i = i+1;
end


%% Create output variable
raw_date = reshape([raw_date{:}],size(raw_date));

for k=1:length(raw_elevation)
    SunElevationDay(i,:) = rad2deg(unwrap(deg2rad(raw_elevation(days(k),:))));
    SunAzimuthDay(i,:) = rad2deg(unwrap(deg2rad(raw_azimuth(days(k),:))));
    DateDay(i) = raw_date(k);
    i = i + 1;
end

% Equinoxes and Solstices
% March 21 - Autumn - Day 80 / % September 21 Spring - Day 264
% June 21 - Winter - Day 172
% December 21 - Summer - Day 355
days =[80,172,355];

i=1;
for k=1:length(days)
    SunElevationDay(i,:) = rad2deg(unwrap(deg2rad(raw_elevation(days(k),:))));
    SunAzimuthDay(i,:) = rad2deg(unwrap(deg2rad(raw_azimuth(days(k),:))));
    DateDay(i) = raw_date(k);
    i = i + 1;
end

%% Clear temporary variables
clearvars raw_sundata raw_azimuth raw_elevation raw_time raw_date R i j k str;

[n m] = size(SunAzimuthDay)'

fig1 = figure;
for i=1:n
    plot(SunAzimuthDay(i,:),SunElevationDay(i,:))
    hold on
end
hold off

fig2 = figure;
for i=1:n
    plot(SunAzimuthDay(i,:))
    hold on
end
hold off
