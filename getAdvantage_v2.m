% clear workspace
clear
clc

%% import data
filename = '117_contingency_2013_Dec_12_1601.log';
fid = fopen(filename);
mydata = textscan(fid, '%f %*s %s','Delimiter','\t');
time = mydata{1,1};
event = mydata{1,2};
subj = str2num(filename(1:3));
%savename = 'group.mat';

%% get rows of events of interest
% find the row index of every left button press
idx = strfind(event,'''pressed'': True, ''port'': 0, ''key'': 0, ''time'': 0'); 
tableLeft = find(not(cellfun('isempty',idx))); 

% find the row index of every left button reward
idx = strfind(event,'earn L'); 
idxEarnLeft = find(not(cellfun('isempty',idx))); 

% find the row index of every right button press
idx = strfind(event,'''pressed'': True, ''port'': 0, ''key'': 1, ''time'': 0'); 
tableRight = find(not(cellfun('isempty',idx))); 

% find the row index of every right button reward
idx = strfind(event,'earn R'); 
idxEarnRight = find(not(cellfun('isempty',idx))); 

%% Get the trial beginning

% get the row index of the block start (beginrow):
idx = strfind(event,'end rating B'); 
beginrow = find(not(cellfun('isempty',idx)));  

idx = strfind(event,'begin trial');
beginrow(end+1,1) = find(not(cellfun('isempty',idx)));
beginrow = sort(beginrow);

% get the time of first scan for later
idx = strfind(event,'''pressed'': False, ''port'': 0, ''key'': 4, ''time'': 0');
triggertime = find(not(cellfun('isempty',idx)));
triggertime = time(triggertime(1));

%% identify rewarded trials
idxRewRight = zeros(length(tableRight),1);
for i = 1:length(idxEarnRight)
    startrow = idxEarnRight(i);
    idx = find(startrow > tableRight,1,'last');
    idxRewRight(idx) = 1;
end

idxRewLeft = zeros(length(tableLeft),1);
for i = 1:length(idxEarnLeft)
    startrow = idxEarnLeft(i);
    idx = find(startrow > tableLeft,1,'last');
    idxRewLeft(idx) = 1;
end

%% create table of "row","block","response","reward"
tableLeft(:,2) = time(tableLeft(:,1),1); % time
tableLeft(:,3) = 0; % block
for i = 1:length(beginrow)-1
    j = find(beginrow(i)<tableLeft(:,1),1,'first');
    k = find(tableLeft(:,1)<beginrow(i+1),1,'last');
    tableLeft(j:k,3)= i;
end
tableLeft(:,4) = 1; % responses
tableLeft(:,5) = 0; % blank
tableLeft(:,6) = idxRewLeft; % rewards
tableLeft(:,7) = 0; % blank

tableRight(:,2) = time(tableRight(:,1),1); % time
tableRight(:,3) = 0; % block
for i = 1:length(beginrow)-1
    j = find(beginrow(i)<tableRight(:,1),1,'first');
    k = find(tableRight(:,1)<beginrow(i+1),1,'last');
    tableRight(j:k,3)= i;
end
tableRight(:,4) = 0; % blank
tableRight(:,5) = 1; % responses
tableRight(:,6) = 0; % blank
tableRight(:,7) = idxRewRight; % rewards

%% Calculate relative advantage in each block (block_Adv)
block_Adv = zeros(6,1);

% alpha (A) = number of rewarded responses (hits)
% beta (B) = number of nonrewarded responses (misses)
% sumAlphaBeta (A+B) = total number of all responses
% mu = contingency P(O|A) = A/(A+B)
% sigma = (A*B/(A+B)^2)/(A+B+1)

for b = 1:6
    % Calcuate alpha and beta for left and right responses
    rows = find(tableLeft(:,3) == b); % find rows in current block
    left_sumalphabeta = length(rows); % sum all left responses
    left_alpha = sum(tableLeft(rows,6))+1.1; % sum all left rewards + prior
    left_beta = left_sumalphabeta - left_alpha+1.1; % calculate nonrewarded left
    
    % Calculate mu and sigma
    left_mu = left_alpha./left_sumalphabeta; 
    left_sigma = (left_alpha.*left_beta)./...
        ((left_sumalphabeta^2).*(1+left_sumalphabeta)); 
    
    rows = find(tableRight(:,3) == b);
    right_sumalphabeta = length(rows);
    right_alpha = sum(tableRight(rows,7))+1.1;
    right_beta = right_sumalphabeta - right_alpha+1.1;
    right_mu = right_alpha./right_sumalphabeta;
    
    right_sigma = (right_alpha.*right_beta)./...
        ((right_sumalphabeta^2).*(1+right_sumalphabeta));
    
    % calculate delta mu and sigma (left - right)
    delta_mu = left_mu - right_mu;
    sumsigma = left_sigma + right_sigma;
    
    % calculate new alpha and new beta from mu and sigma
    new_mu = delta_mu./2 + 0.5;
    new_sigma = sumsigma./4;
    new_alpha = (new_mu^2).*(((1-new_mu)./new_sigma)-1./new_mu);
    new_beta = new_alpha.*((1./new_mu) - 1);
    
    % calculate right advantage
    block_Adv(b,1) = betacdf(0.5, new_alpha, new_beta);
end

%% Create a new table
table = [tableLeft;tableRight];
table = sortrows(table,1);
table(:,2) = table(:,2) - triggertime;

%% Calculate relative advantage for each response
table(:,8:24)=0;

for b = 1:6
    firstrow = find(table(:,3)==b,1,'first');
    lastrow = find(table(:,3)==b,1,'last');
    table(firstrow:lastrow,8) = cumsum(table(firstrow:lastrow,4))+2.2; % left_sumAlphaBeta
    table(firstrow:lastrow,9) = cumsum(table(firstrow:lastrow,5))+2.2; % right_sumAlphaBeta
    table(firstrow:lastrow,10) = cumsum(table(firstrow:lastrow,6))+1.1; % left_Alpha
    table(firstrow:lastrow,11) = cumsum(table(firstrow:lastrow,7))+1.1; % right_Alpha
end

table(:,12) = table(:,8) - table(:,10)+1.1; % left_Beta
table(:,13) = table(:,9) - table(:,11)+1.1; % right_Beta
table(:,14) = table(:,10)./table(:,8); % left_Mu
table(:,15) = table(:,11)./table(:,9); % right_Mu


table(:,16) = (table(:,10).*table(:,12))./...
    ((table(:,8).^2).*(1+table(:,8))); % left_Sigma

table(:,17) = (table(:,11).*table(:,13))./...
    ((table(:,9).^2).*(1+table(:,9))); % right_Sigma

%% Calculate delta (left ? right)
table(:,18) = table(:,14) - table(:,15); % delta_mu
table(:,19) = table(:,16) + table(:,17); % sumsigma

%% Calculate right advantage (??)
table(:,20) = table(:,18)./2 + 0.5; % new_mu
table(:,21) = table(:,19)./4; % new_sigma

table(:,22) = (table(:,20).^2).*...
    (((1-table(:,20))./table(:,21))-1./table(:,20)); % new_alpha

table(:,23) = table(:,22).*((1./table(:,20))-1); % new_beta

table(:,24) = betacdf(0.5,table(:,22),table(:,23)); % right advantage

%% Create SOTS and pmod
