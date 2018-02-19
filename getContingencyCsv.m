% clear workspace
clear
clc

%% Initialize variables.
filename = '227_contingency_2014_Aug_21_1227conditions.csv';
delimiter = ',';
startRow = 2;
endRow = 7;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fid = fopen(filename,'r');
textscan(fid, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
dataArray = textscan(fid, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'ReturnOnError', false);

mydata = [dataArray{1:end-1}];

clear filename delimiter startRow endRow formatSpec fid dataArray ans;

%% Close the text file.
fclose(fid);