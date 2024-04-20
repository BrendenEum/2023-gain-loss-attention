        % File: convert2csv.m
% Programer: Stephen A. Gonzalez
% Date Created: 12/1/2021
% ---------------------------------------------------------------------------
% Purpose: Process and export subject experimental choice data into csv files

% ---------------------------------------------------------------------------
% Required files: 
%   -- expdata_SID.mat

% ---------------------------------------------------------------------------
% Output(s): Located in the csvdata_output folder
%   -- choice_SID_win.csv
%   -- choice_SID_loss.csv
%   

%% Clear Workspace
clear
close all
clc


%% Set up
cd ~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data %Path to data

SIDs = [9390,9440]; %SIDs of participants to process


% Batch processing Loop
for SID = SIDs
    %% Read in data
    cd ~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data %Path to data
    disp(['Processing subject ' num2str(SID) '...']); % Display info to command window

    fileName = [pwd '/' num2str(SID) '/expdata_' num2str(SID) '.mat']; % Get the filename of the Subject's expdata
    load(fileName); % Load Subject's data
    
    % Open Choice CSV's
    choice_csv_win = fopen([pwd '/' num2str(SID) '/choice_' num2str(SID) '_win.csv'],'w');
    choice_csv_loss = fopen([pwd '/' num2str(SID) '/choice_' num2str(SID) '_loss.csv'],'w');
    
    % Write a header to the choice csv file
    header = ['subject_ID,trial_number,trial_type,p_left,p_right,choice,RT\n'];
    fprintf(choice_csv_win, header);
    fprintf(choice_csv_loss,header);

    % Open raw Eye Fixation CSVs
    eyeFix_csv_win = fopen([pwd '/' num2str(SID) '/raw_fixations_' num2str(SID) '_win.csv'],'w');
    eyeFix_csv_loss = fopen([pwd '/' num2str(SID) '/raw_fixations_' num2str(SID) '_loss.csv'],'w');
    
    % Writer header to the Eye Fixation csv file
    header = ['subject_ID,trial_number,timeStamp,location,ROI,x_position,y_position,pupil_dilation\n'];
    fprintf(eyeFix_csv_win, header);
    fprintf(eyeFix_csv_loss, header);


    %% Win BLOCK
    % READ IN DATA
    cd ~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/code/data_processing_code %Path to script
    [fixTime, fixLocX, fixLocY, fixItem, fixPupArea, trialDuration,transitionTime, mergedBlankFixations, RawFixTime, RawFixLocX, RawFixLocY, RawFixItem,RawFixPupArea, rawXSamples, rawYSamples, rawTimeStampSamples, rawPupAreaSamples, rawItemSamples,potentiallyBadTrials, data]...
        = ReadFixations(SID,data,'win');

    for trialNum = 1:data.numTrials
        
        % Choice File write out
        % Assign choice made for a given trial 
        if data.win_choice(trialNum) == 1
            choice = 'left';
        elseif data.win_choice(trialNum) == 2
            choice = 'right';
        end
    
        % Format data string for win file
        win_line = sprintf('%d,%d,%s,%d,%d,%s,%.4f\n', ...
            SID,trialNum,'win',data.win_StimProb_left(trialNum), ...
            data.win_StimProb_right(trialNum),choice,data.win_RT(trialNum));
        
        % Write Line to win file
        fprintf(choice_csv_win,win_line); 
        

        % Eye-Tracking file writeout
        for ii=1:length(rawXSamples{trialNum})
            item = rawItemSamples{trialNum}(ii);
            if item == 1
                ROI = 'left';
            elseif item == 2
                ROI = 'right';
            elseif item == 3
                ROI = 'fixCross';
            elseif item == 4 || item == 0
                ROI = 'None';
            end
            fprintf(eyeFix_csv_win, '%d,%d,%f,%d,%s,%f,%f,%f\n', SID, trialNum, rawTimeStampSamples{trialNum}(ii), item, ROI, rawXSamples{trialNum}(ii), rawYSamples{trialNum}(ii), rawPupAreaSamples{trialNum}(ii)); %Write formatted ROW to file
        end
    end
    

    %% Loss Block
    % READ IN DATA
    cd ~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/code/data_processing_code %Path to script
    [fixTime, fixLocX, fixLocY, fixItem, fixPupArea, trialDuration,transitionTime, mergedBlankFixations, RawFixTime, RawFixLocX, RawFixLocY, RawFixItem,RawFixPupArea, rawXSamples, rawYSamples, rawTimeStampSamples, rawPupAreaSamples, rawItemSamples,potentiallyBadTrials, data]...
        = ReadFixations(SID,data,'los');

    for trialNum = 1:data.numTrials
        
        % Choice File write out
        % Assign choice made for a given trial 
        if data.loss_choice(trialNum) == 1
            choice = 'left';
        elseif data.loss_choice(trialNum) == 2
            choice = 'right';
        end
    
        % Format data string for win file
        loss_line = sprintf('%d,%d,%s,%d,%d,%s,%.4f\n', ...
            SID,trialNum,'loss',data.loss_StimProb_left(trialNum), ...
            data.loss_StimProb_right(trialNum),choice,data.loss_RT(trialNum));
        
        % Write Line to win file
        fprintf(choice_csv_loss,loss_line); 
    
        % Eye-Tracking file writeout
        for ii=1:length(rawXSamples{trialNum})
            item = rawItemSamples{trialNum}(ii);
            if item == 1
                ROI = 'left';
            elseif item == 2
                ROI = 'right';
            elseif item == 3
                ROI = 'fixCross';
            elseif item == 4 || item == 0
                ROI = 'None';
            end
            fprintf(eyeFix_csv_loss, '%d,%d,%f,%d,%s,%f,%f,%f\n', SID, trialNum, rawTimeStampSamples{trialNum}(ii), item, ROI, rawXSamples{trialNum}(ii), rawYSamples{trialNum}(ii), rawPupAreaSamples{trialNum}(ii)); %Write formatted ROW to file
        end
    end
    
    fclose('all');
end