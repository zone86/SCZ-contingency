% clear workspace
clear
clc

%% import data
filename = '226_contingency_2014_Aug_11_1225.log';
savename = 'delete';
fid = fopen(filename);
mydata = textscan(fid, '%f %*s %s','Delimiter','\t');
time = mydata{1,1};
event = mydata{1,2};
clear fid mydata

%% Get the trial start and end times

% get the trial start times: 
idx = strfind(event,'end rating R'); %returns a cell of 1 for every true event
idxRow = not(cellfun('isempty',idx)); %returns an array of every row = 1 
endBlock = time(idxRow);
clear idx idxRow

idx = strfind(event,'Keypress: space');
idxRow = find(not(cellfun('isempty',idx)));
pressSpace = time(idxRow);
trialStarts = [pressSpace;endBlock];
trialStarts = trialStarts(1:end-1);
clear idx idxRow pressSpace

% get the trial end times:
idx = strfind(event,'start rating L');
idxRow = find(not(cellfun('isempty',idx)));
trialEnds = time(idxRow);
clear idx idxRow

%% Get ratings in each block (rating A, rating B)
ratings = zeros(6,2);
idx = strfind(event,'end rating L'); %returns a cell of 1 for every true event
index = find(not(cellfun('isempty',idx))); %returns an array of every row = 1
for b = 1:size(index,1)
    rating = str2num(cell2mat(event(index(b)-1,1)));
    ratings(b,1) = rating;
end

idx = strfind(event,'end rating R'); %returns a cell of 1 for every true event
index = find(not(cellfun('isempty',idx))); %returns an array of every row = 1
for b = 1:size(index,1)
    rating = str2num(cell2mat(event(index(b)-1,1)));
    ratings(b,2) = rating;
end
clear idx index rating

%% Get the number of responses in each block (left, right)

% get the time of every left response (Keypress: t):
idx = strfind(event,'Keypress: t'); 
idxRow = find(not(cellfun('isempty',idx))); 
idxTimes = time(idxRow); %creates an array of times (from time array)

% get number of times in each block:
respLeft = cell(1,6);
for b = 1:6
   idxRow = find(trialStarts(b) < idxTimes & idxTimes < trialEnds(b));
   respLeft{b} = idxTimes(idxRow);
end
clear idx idxRow idxTimes

% Get the number of right responses in each block (Keypress: v)

% get the time of every right response:
idx = strfind(event,'Keypress: v'); %returns a cell of 1s for every true event
idxRow = find(not(cellfun('isempty',idx))); %returns an array for every 1 row index
idxTimes = time(idxRow); %creates an array of times (from time array)

% get number of times in each block:
respRight = cell(1,6);
for b = 1:6
   idxRow = find(trialStarts(b) < idxTimes & idxTimes < trialEnds(b));
   respRight{b} = idxTimes(idxRow);
end
clear idx idxRow idxTimes

responses = zeros(6,2);
for b = 1:6
    responses(b,1) = length(respLeft{b});
    responses(b,2) = length(respRight{b});
end

%% Get the number of left outcomes in each block (earned)

% create a list of the time of every 'earn t':
idx = strfind(event,'earn t'); %returns a cell of 1s for every true event
idxRow = find(not(cellfun('isempty',idx))); %returns an array for every 1 row index
idxTimes = time(idxRow); %creates an array of times (from time array)

% count the times in each block:
earnLeft = cell(1,6);
for b = 1:6
   idxRow = find(trialStarts(b) < idxTimes & idxTimes < trialEnds(b));
   earnLeft{b} = idxTimes(idxRow);
end
clear idx idxRow idxTimes

%% Get the number of right outcomes in each block (earned)

% get a list of the time of every 'earn v':
idx = strfind(event,'earn v'); %returns a cell of 1s for every true event
idxRow = find(not(cellfun('isempty',idx))); %returns an array for every 1 row index
idxTimes = time(idxRow); %creates an array of times (from time array)

% count the times in each block:
earnRight = cell(1,6);
for b = 1:6
   idxRow = trialStarts(b) < idxTimes & idxTimes < trialEnds(b);
   earnRight{b} = idxTimes(idxRow);
end
clear idx idxRow idxTimes

outcomes = zeros(6,2);
for b = 1:6
    outcomes(b,1) = length(earnLeft{b});
    outcomes(b,2) = length(earnRight{b});
end

%% Calculate the outcome contingency in each block

contingencies = outcomes./responses;

%% sort trials into high vs low, and nondegraded vs degraded, then average
d = contingencies(:,1) - contingencies(:,2);
sortedResponses = zeros(6,4);
sortedRatings = zeros(6,4);
sortedContingencies = zeros(6,4);

for i = 1:6;
    if d(i) < 0
        sortedResponses(i,1) = responses(i,2); sortedResponses(i,2) = responses(i,1);
        sortedRatings(i,1) = ratings(i,2); sortedRatings(i,2) = ratings(i,1);
        sortedContingencies(i,1) = contingencies(i,2); sortedContingencies(i,2) = contingencies(i,1);
    else
        sortedResponses(i,1) = responses(i,1); sortedResponses(i,2) = responses(i,2);
        sortedRatings(i,1) = ratings(i,1); sortedRatings(i,2) = ratings(i,2); 
        sortedContingencies(i,1) = contingencies(i,1); sortedContingencies(i,2) = contingencies(i,2);
    end
end
clear i

sortedResponses(1,3) = responses(1,1); sortedResponses(1,4) = responses(1,2);
sortedResponses(2,3) = responses(2,2); sortedResponses(2,4) = responses(2,1);
sortedResponses(3,3) = responses(3,2); sortedResponses(3,4) = responses(3,1);
sortedResponses(4,3) = responses(4,1); sortedResponses(4,4) = responses(4,2);
sortedResponses(5,3) = responses(5,2); sortedResponses(5,4) = responses(5,1);
sortedResponses(6,3) = responses(6,1); sortedResponses(6,4) = responses(6,2);

sortedRatings(1,3) = ratings(1,1); sortedRatings(1,4) = ratings(1,2);
sortedRatings(2,3) = ratings(2,2); sortedRatings(2,4) = ratings(2,1);
sortedRatings(3,3) = ratings(3,2); sortedRatings(3,4) = ratings(3,1);
sortedRatings(4,3) = ratings(4,1); sortedRatings(4,4) = ratings(4,2);
sortedRatings(5,3) = ratings(5,2); sortedRatings(5,4) = ratings(5,1);
sortedRatings(6,3) = ratings(6,1); sortedRatings(6,4) = ratings(6,2);

sortedContingencies(1,3) = contingencies(1,1); sortedContingencies(1,4) = contingencies(1,2);
sortedContingencies(2,3) = contingencies(2,2); sortedContingencies(2,4) = contingencies(2,1);
sortedContingencies(3,3) = contingencies(3,2); sortedContingencies(3,4) = contingencies(3,1);
sortedContingencies(4,3) = contingencies(4,1); sortedContingencies(4,4) = contingencies(4,2);
sortedContingencies(5,3) = contingencies(5,2); sortedContingencies(5,4) = contingencies(5,1);
sortedContingencies(6,3) = contingencies(6,1); sortedContingencies(6,4) = contingencies(6,2);

meanResponses = mean(sortedResponses);
meanRatings = mean(sortedRatings);
meanContingencies = mean(sortedContingencies);

disp('   Average responses')
disp('   high     low        hi       lo')
disp(meanResponses)
disp(' ')
disp('    Average ratings')
disp('    high      low       hi        lo')
disp(meanRatings)
disp(' ')
disp('    Average contingency')
disp('    high      low       hi        lo')
disp(meanContingencies)


%% plot figure
figure(1)

% plot ratings
subplot(2,2,1); bar(ratings); title('ratings')
set(gca,'YLim',[0 8])

%plot outcomes
subplot(2,2,2); bar(outcomes); title('outcomes')

% plot responses
subplot(2,2,3);bar(responses);title('responses')

% plot contingencies
subplot(2,2,4);bar(contingencies);title('contingencies')
set(gca,'YLim',[0 0.2])

%% save workspace
%save(savename)
