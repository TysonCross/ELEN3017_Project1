DeclinationAngle = 23.45 * sin(360./365.*(datenum(dateMonthDay) + 284));
plot(datenum(dateMonthDay(1)),DeclinationAngle(1))
