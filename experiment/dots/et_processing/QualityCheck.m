% File: QualityCheck.m
% Programer: Stephen A. Gonzalez
% Date Created: 3/7/2022
% ---------------------------------------------------------------------------
% Purpose: Check the Quality of the data

% ---------------------------------------------------------------------------
% Required files: 
%   -- expdata_SID.mat
%   -- SID_win.asc
%   -- SID_los.asc

% ---------------------------------------------------------------------------
% Output(s): 
%   -- Will output data quality report to the console 


%% Clear Workspace
clear
close all
clc


%% Set up
SID = [1094];



%% WIN BLOCK
% Read in data
fileName = ['~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data/' num2str(SID) '/expdata_' num2str(SID) '.mat']; % Get the filename of the Subject's expdata
    load(fileName); % Load Subject's data

[fixTime, fixLocX, fixLocY, fixItem, ~, trialDuration,transitionTime, mergedBlankFixations, RawFixTime, RawFixLocX, RawFixLocY, RawFixItem,RawFixPupArea, rawXSamples, rawYSamples, rawTimeStampSamples, rawPupAreaSamples, rawItemSamples,potentiallyBadTrials]...
        = ReadFixations(SID,data,'win');


%% Check reaction time in milliseconds
%fprintf('WIN BLOCK:');
%fprintf('CHECK REACTION TIME:');
cprintf('green','WIN BLOCK:\n');
cprintf([1,0,1], 'CHECK REACTION TIME:\n');

eyelinkRT = trialDuration';
matlabRT = data.win_RT'*1000;
[rRT, pRT] = corr(eyelinkRT, matlabRT);

% Can also check the number of "bad" trials
if rRT<.9
    disp(['Correlation between Matlab and Eyelink Choice trial RTs is ' num2str(rRT) ',']); cprintf('err', 'BAD SUBJECT\n');
else
    disp(['Correlation between Matlab and Eyelink Choice trial RTs is ' num2str(rRT)])
end

avgRT = mean(matlabRT);
if avgRT < 1000 || avgRT > 5000
    disp(['Average Matlab Choice trial RT is ' num2str(avgRT/1000) ' seconds']); cprintf('err', 'BAD SUBJECT\n');
else
    disp(['Average Matlab Choice trial RT is ' num2str(avgRT/1000) ' seconds'])
end

if length(potentiallyBadTrials)>10
    disp([num2str(length(potentiallyBadTrials)) ' trials do not start with fixation cross fixation, maybe bad'])
else
    disp([num2str(length(potentiallyBadTrials)) ' trials do not start with fixation cross fixation'])
end
%}

% Check eye-Tracking quality (% lost data)
%fprintf('\n\nCHECK EYE-TRACKING QUALITY:\n');
cprintf([1,0,1], '\nCHECK EYE-TRACKING QUALITY:\n');
trials = length(rawXSamples);
    totalSamples = 0;
    nullSamples = 0;
    badTrials = [];
    invalidTrials = [];
    for i = 1:trials
        missing = isnan(rawXSamples{i});
        totalSamples = totalSamples + length(missing);
        nullSamples = nullSamples + sum(missing);
        byTrialMissing(i) = mean(missing);
        percentLostByTrial(i) = mean(missing);
        if mean(missing) > .1
            badTrials = [badTrials i];
        end


        % Check if valid
        badTrial(i) = mean((rawItemSamples{i}==0)|(rawItemSamples{i}==4));
        if badTrial(i)>.5
            invalidTrials = [invalidTrials i];
        end
    end
    percentLost = nullSamples/totalSamples;

    disp(['Number invalid trials: ' num2str(length(invalidTrials))])

    if percentLost > .1
        disp(['Percent of missing ET data is ' num2str(percentLost)]); cprintf('err', 'BAD SUBJECT\n');
    else
        disp(['Percent of missing ET data is ' num2str(percentLost)])
    end

    if mean(byTrialMissing) > .1
        disp(['Percent of missing ET data equal weighting is ' num2str(mean(byTrialMissing))]); cprintf('err', 'BAD SUBJECT\n');
    else
        disp(['Percent of missing ET data equal weighting is ' num2str(mean(byTrialMissing))])
    end
    disp('Trials missing more than 10% of ET data: ')
    disp(badTrials)

    worstTrial = max(percentLostByTrial);


%% Check if subject is randomly making choices
%fprintf('\nCHECK IF SUBJECT IS RANDOMLY MAKING CHOICES:\n');
cprintf([1,0,1], 'CHECK IF SUBJECT IS RANDOMLY MAKING CHOICES:\n');
data.win_StimProb_left = data.win_StimProb_left';
data.win_StimProb_right = data.win_StimProb_right';
data.win_correctOption = [];

for ii = 1:(data.numTrials)
    if data.win_StimProb_left(ii) > data.win_StimProb_right(ii)
       data.win_correctOption(ii) =  1;

    elseif data.win_StimProb_left(ii) < data.win_StimProb_right(ii)
       data.win_correctOption(ii) = 2;     

    elseif data.win_StimProb_left(ii) == data.win_StimProb_right(ii)
        data.win_correctOption(ii) = data.win_choice(ii);
    end
end
data.win_correctOption = data.win_correctOption';

data.win_choice = data.win_choice';
data.win_choiceCorrect = data.win_correctOption == data.win_choice;

%tabulate(data.win_choiceCorrect);
%sum(isnan(data.win_correctOption));

% Check if subject is randomly making choices
correctChoices = data.win_choiceCorrect;
x = sum(correctChoices,'omitnan');
N = length(correctChoices);
perCor = x/N;
prob = 1/2;
pChoice = myBinomTest(x,N,prob);

if pChoice > .05
    disp(['p Value of Binomial Test of correct choices different than 1/2 is ' num2str(pChoice)]); cprintf('err', 'BAD SUBJECT\n');
    disp(['Percent "correct" choices: ' num2str(perCor)])
else
    disp(['p Value of Binomial Test of correct choices different than 1/2 is ' num2str(pChoice)])
    disp(['Percent "correct" choices: ' num2str(perCor)])
end

%% SEPERATOR
fprintf('\n\n------------------------------------------------------------------------------\n\n');


%% LOSS BLOCK
% Read in data
[fixTime, fixLocX, fixLocY, fixItem, fixPupArea, trialDuration,transitionTime, mergedBlankFixations, RawFixTime, RawFixLocX, RawFixLocY, RawFixItem,RawFixPupArea, rawXSamples, rawYSamples, rawTimeStampSamples, rawPupAreaSamples, rawItemSamples,potentiallyBadTrials]...
        = ReadFixations(SID,data,'los');


%% Check reaction time in milliseconds
%fprintf('WIN BLOCK:');
%fprintf('CHECK REACTION TIME:');
cprintf([180, 0, 0],'\nLOSS BLOCK:\n');
cprintf([1,0,1], 'CHECK REACTION TIME:\n');

eyelinkRT = trialDuration';
matlabRT = data.loss_RT'*1000;
[rRT, pRT] = corr(eyelinkRT, matlabRT);

% Can also check the number of "bad" trials
if rRT<.9
    disp(['Correlation between Matlab and Eyelink Choice trial RTs is ' num2str(rRT) ',']); cprintf('err', 'BAD SUBJECT\n');
else
    disp(['Correlation between Matlab and Eyelink Choice trial RTs is ' num2str(rRT)])
end

avgRT = mean(matlabRT);
if avgRT < 1000 || avgRT > 5000
    disp(['Average Matlab Choice trial RT is ' num2str(avgRT/1000) ' seconds']); cprintf('err', 'BAD SUBJECT\n');
else
    disp(['Average Matlab Choice trial RT is ' num2str(avgRT/1000) ' seconds'])
end

if length(potentiallyBadTrials)>10
    disp([num2str(length(potentiallyBadTrials)) ' trials do not start with fixation cross fixation, maybe bad'])
else
    disp([num2str(length(potentiallyBadTrials)) ' trials do not start with fixation cross fixation'])
end
%}

% Check eye-Tracking quality (% lost data)
%fprintf('\n\nCHECK EYE-TRACKING QUALITY:\n');
cprintf([1,0,1], '\nCHECK EYE-TRACKING QUALITY:\n');
trials = length(rawXSamples);
    totalSamples = 0;
    nullSamples = 0;
    badTrials = [];
    invalidTrials = [];
    for i = 1:trials
        missing = isnan(rawXSamples{i});
        totalSamples = totalSamples + length(missing);
        nullSamples = nullSamples + sum(missing);
        byTrialMissing(i) = mean(missing);
        percentLostByTrial(i) = mean(missing);
        if mean(missing) > .1
            badTrials = [badTrials i];
        end


        % Check if valid
        badTrial(i) = mean((rawItemSamples{i}==0)|(rawItemSamples{i}==4));
        if badTrial(i)>.5
            invalidTrials = [invalidTrials i];
        end
    end
    percentLost = nullSamples/totalSamples;

    disp(['Number invalid trials: ' num2str(length(invalidTrials))])

    if percentLost > .1
        disp(['Percent of missing ET data is ' num2str(percentLost)]); cprintf('err', 'BAD SUBJECT\n');
    else
        disp(['Percent of missing ET data is ' num2str(percentLost)])
    end

    if mean(byTrialMissing) > .1
        disp(['Percent of missing ET data equal weighting is ' num2str(mean(byTrialMissing))]); cprintf('err', 'BAD SUBJECT\n');
    else
        disp(['Percent of missing ET data equal weighting is ' num2str(mean(byTrialMissing))])
    end
    disp('Trials missing more than 10% of ET data: ')
    disp(badTrials)

    worstTrial = max(percentLostByTrial);


%% Check if subject is randomly making choices
%fprintf('\nCHECK IF SUBJECT IS RANDOMLY MAKING CHOICES:\n');
cprintf([1,0,1], 'CHECK IF SUBJECT IS RANDOMLY MAKING CHOICES:\n');
data.loss_StimProb_left = data.loss_StimProb_left';
data.loss_StimProb_right = data.loss_StimProb_right';
data.loss_correctOption = [];

for ii = 1:(data.numTrials)
    if data.loss_StimProb_left(ii) < data.loss_StimProb_right(ii)
       data.loss_correctOption(ii) =  1;

    elseif data.loss_StimProb_left(ii) > data.loss_StimProb_right(ii)
       data.loss_correctOption(ii) = 2;     

    elseif data.loss_StimProb_left(ii) == data.loss_StimProb_right(ii)
        data.loss_correctOption(ii) = data.loss_choice(ii);
    end
end
data.loss_correctOption = data.loss_correctOption';

data.loss_choice = data.loss_choice';
data.loss_choiceCorrect = data.loss_correctOption == data.loss_choice;

%tabulate(data.win_choiceCorrect);
%sum(isnan(data.win_correctOption));

% Check if subject is randomly making choices
correctChoices = data.loss_choiceCorrect;
x = sum(correctChoices,'omitnan');
N = length(correctChoices);
perCor = x/N;
prob = 1/2;
pChoice = myBinomTest(x,N,prob,'one');

if pChoice > .05
    disp(['p Value of Binomial Test of correct choices different than 1/2 is ' num2str(pChoice)]); cprintf('err', 'BAD SUBJECT\n');
    disp(['Percent "correct" choices: ' num2str(perCor)]);
else
    disp(['p Value of Binomial Test of correct choices different than 1/2 is ' num2str(pChoice)])
    disp(['Percent "correct" choices: ' num2str(perCor)]);
end











