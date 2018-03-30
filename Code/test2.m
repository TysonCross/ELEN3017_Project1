clc; clear all;
fig1 = figure;
date_days = [1:366]
angle = degtorad(360./365.*date_days + 284)
DeclinationAngle = 23.45 * sin(angle)
plot(date_days,DeclinationAngle)
