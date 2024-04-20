    % File: main_task.m
% Programer: Stephen A. Gonzalez
% Date Created: 11/16/2021
% Purpose: 

% ---------------------------------------------------------------------------
% Instructions: 
%   Run by clicking the "Run" Icon on the Editor toolbar
%   Enter Subject ID (SID)
%   Enter Block Type: "win" or "los"
%   Setup and Calibrate the subject
%   Validate the Calibration
%   Run experiment
%   Once the task is finished and you're on the END SCREEN 
%       press "e" to close the task and save out the data
% ---------------------------------------------------------------------------
% Output(s):
%   expdata_SID_Setup.mat
%   expdata_SID.mat
%   SID_win.edf
%   SID_los.edf

%% SET UP EXPERIMENT
clear;
SID = input('Enter SID: ','s'); %Request Subject ID

%Request Block Type
while true 
    block_type = input('Enter Block Type: ','s'); %Request Block Type
    
    if strcmp(block_type, 'win') || strcmp(block_type, 'los') %Only exit once the appropriate input has been given
        break;   
    end
end

expdata = SetupTask(SID);
expdata.firstBlock = block_type;
expdata.curBlock = 0;
SaveWithoutOverwrite([expdata.fname '_Setup'], expdata);


%% EYE-TRACKING SETUP
if expdata.etSwitch == 1
    eyeLink = EyelinkInitDefaults(expdata.windowPtr);

    % Initialization of the connection with the Eyelink Gazetracker.
    % Exit program if this fails.
    dummyMode = 0; % 1 = run in dummy mode, 0 = run for real
    if ~EyelinkInit(dummyMode)
        disp('Eyelink Init aborted.');
        FinalCleanUp;
        return;
    end

    % Open file to record data to.
    expdata.edfFile = [expdata.SID '_' block_type '.edf'];    
    res = Eyelink('OpenFile', expdata.edfFile);
    if res~=0
        fprintf('Cannot create EDF file ''%s''\n', expdata.edfFile);
        CloseExperiment(expdata);
        return;
    end

    % Retrieve eye tracker version.
    [~, vs] = Eyelink('GetTrackerVersion');

    % Set EDF file contents.
    if vs >=4 
        Eyelink('Command', ['file_sample_data = ' ...
            'LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT']);
        Eyelink('Command', ['link_sample_data = ' ...
            'LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT']);       
    else
        Eyelink('Command', ['file_sample_data = ' ...
            'LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT']);
        Eyelink('Command', ['link_sample_data = ' ...
            'LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT']);
    end

    Eyelink('Command', ['add_file_preamble_text "Recorded by ' ...
        'EyelinkToolbox for Experiment ' ...
        'by StephenG"']);

    % Make sure we are still connected.
    if Eyelink('IsConnected') ~= 1 && dummyMode == 0
        disp('Not connected to eye tracker, cleaning up.');
        FinalCleanUp;
        return;
    end

    % Set calibration and text parameters.
    Eyelink('Command', 'calibration_type = HV5');
    eyeLink.backgroundcolour = 0;    
    eyeLink.calibrationtargetcolour = [255 255 255];
    eyeLink.msgfont = expdata.textFont;
    eyeLink.msgfontsize = expdata.textSize;
    eyeLink.msgfontcolour = expdata.colorText;
    EyelinkUpdateDefaults(eyeLink);

    % Calibrate the eye tracker.
    EyelinkDoTrackerSetup(eyeLink);

    % Do a final check of calibration using drift correction.
    success = EyelinkDoDriftCorrection(eyeLink);
    if success~=1
        CloseExperiment(expdata);
        disp('Eyelink calibration failed.');
        return;
    end
end


%% Experiment
if expdata.etSwitch == 1
    Eyelink('Command', 'record_status_message "Practice BLOCK"');
end


%% PRACTICE TRIALS
if expdata.practiceSwitch == true
    % Begin screen
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
    text = sprintf(['Practice trials about to begin...']);
    DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
    Screen(expdata.windowPtr, 'Flip');
    WaitSecs(2);

    for trialNum = 1:16
        expdata.trialNum = trialNum;

        if expdata.etSwitch == 1
            run_practice_trials(expdata,eyeLink);
        else
            run_practice_trials(expdata);
        end
        
    end
end


%% BLOCK 1
expdata.curBlock = expdata.curBlock + 1;
if strcmp(block_type, 'win') %If WIN Block First
    % Begin screen
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
    text = sprintf(['WIN trials about to begin...']);
    DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
    Screen(expdata.windowPtr, 'Flip');
    WaitSecs(2);
    
    if expdata.etSwitch == 1
        Eyelink('Command', 'record_status_message "WIN BLOCK %d"', expdata.curBlock);
    end
    
    % Run Win Block
    for trialNum = 1:expdata.numTrials
        expdata.trialNum = trialNum; %Save current trial number

        if expdata.etSwitch == 1
            expdata = run_win_block(expdata,eyeLink);
        else 
            expdata = run_win_block(expdata);
        end
    end
    
else %If LOSS Block First
    % Begin screen
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
    text = sprintf(['LOSS trials about to begin...']);
    DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
    Screen(expdata.windowPtr, 'Flip');
    WaitSecs(2);    
    
    if expdata.etSwitch == 1
        Eyelink('Command', 'record_status_message "LOSS BLOCK %d"', expdata.curBlock);
    end
    
    % Run Loss Block
    for trialNum = 1:expdata.numTrials
        expdata.trialNum = trialNum; % Save current trial number
        
        if expdata.etSwitch == 1 
            expdata = run_loss_block(expdata,eyeLink);
        else
            expdata = run_loss_block(expdata);
        end

    end
end    
    

%% SAVE OUT BLOCK 1 EYE-TRACKING DATA
if expdata.etSwitch == 1
    % Close eye tracking data file.
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    % Download eye tracking data file.
    try
        fprintf('Receiving data file ''%s''...\n', expdata.edfFile);
        status = Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
    catch
        save(['eyelink_file_error_' datestr(now, 30)]);
        fprintf('Problem receiving data file ''%s''\n', expdata.edfFile);
        psychrethrow(psychlasterror);
    end
end


%% INTERMISSION SCREEN
Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
text = sprintf(['You have completed PART 1 of the experiment.\n\n\n\n\n Feel free to take a break before continueing\n\n Press the SPACE-BAR when ready to continue.']);
DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
Screen(expdata.windowPtr, 'Flip');                                  %Draw previous commands to the screen
KbWaitForKeys(expdata.keySpace, Inf);                               %Wait for user input


%% EYE-TRACKING SETUP
if expdata.etSwitch == 1
    eyeLink = EyelinkInitDefaults(expdata.windowPtr);

    % Initialization of the connection with the Eyelink Gazetracker.
    % Exit program if this fails.
    dummyMode = 0; % 1 = run in dummy mode, 0 = run for real
    if ~EyelinkInit(dummyMode)
        disp('Eyelink Init aborted.');
        FinalCleanUp;
        return;
    end

    % Open file to record data to. Open opposite of starting block 
    if strcmp(block_type, 'win')                       % If starting block win
        expdata.edfFile = [expdata.SID '_los.edf'];   % Open loss edf file 
    elseif strcmp(block_type, 'los')                   % If starting Block loss 
        expdata.edfFile = [expdata.SID '_win.edf'];    % Open Win edf file 
    end

    res = Eyelink('OpenFile', expdata.edfFile);
    if res~=0
        fprintf('Cannot create EDF file ''%s''\n', expdata.edfFile);
        CloseExperiment(expdata);
        return;
    end

    % Retrieve eye tracker version.
    [~, vs] = Eyelink('GetTrackerVersion');

    % Set EDF file contents.
    if vs >=4 
        Eyelink('Command', ['file_sample_data = ' ...
            'LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT']);
        Eyelink('Command', ['link_sample_data = ' ...
            'LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT']);       
    else
        Eyelink('Command', ['file_sample_data = ' ...
            'LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT']);
        Eyelink('Command', ['link_sample_data = ' ...
            'LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT']);
    end

    Eyelink('Command', ['add_file_preamble_text "Recorded by ' ...
        'EyelinkToolbox for Experiment ' ...
        'by StephenG"']);

    % Make sure we are still connected.
    if Eyelink('IsConnected') ~= 1 && dummyMode == 0
        disp('Not connected to eye tracker, cleaning up.');
        FinalCleanUp;
        return;
    end

    % Set calibration and text parameters.
    Eyelink('Command', 'calibration_type = HV5');
    eyeLink.backgroundcolour = 0;    
    eyeLink.calibrationtargetcolour = [255 255 255];
    eyeLink.msgfont = expdata.textFont;
    eyeLink.msgfontsize = expdata.textSize;
    eyeLink.msgfontcolour = expdata.colorText;
    EyelinkUpdateDefaults(eyeLink);

    % Calibrate the eye tracker.
    EyelinkDoTrackerSetup(eyeLink);

    % Do a final check of calibration using drift correction.
    success = EyelinkDoDriftCorrection(eyeLink);
    if success~=1
        CloseExperiment(expdata);
        disp('Eyelink calibration failed.');
        return;
    end
end


%% BLOCK 2
expdata.curBlock = expdata.curBlock + 1;
if strcmp(block_type, 'win')
    % Begin screen
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
    text = sprintf(['LOSS trials about to begin...']);
    DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
    Screen(expdata.windowPtr, 'Flip');
    WaitSecs(2);
    
    if expdata.etSwitch == 1
        Eyelink('Command', 'record_status_message "LOSS BLOCK %d"', expdata.curBlock);
    end
    
    % Run Loss Block
    for trialNum = 1:expdata.numTrials
        expdata.trialNum = trialNum; % Save current trial number

        if expdata.etSwitch == 1
            expdata = run_loss_block(expdata,eyeLink);
        else 
            expdata = run_loss_block(expdata);
        end
    end
    
else
    % Begin screen
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
    text = sprintf(['WIN trials about to begin...']);
    DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
    Screen(expdata.windowPtr, 'Flip');
    WaitSecs(2);
    
    if expdata.etSwitch
        Eyelink('Command', 'record_status_message "WIN BLOCK %d"', expdata.curBlock);
    end
    
    % Run Win Block
    for trialNum = 1:expdata.numTrials
        expdata.trialNum = trialNum; %Save current trial number
    
        if expdata.etSwitch == 1
            expdata = run_win_block(expdata,eyeLink);
        else
            expdata = run_win_block(expdata);
        end
        
    end
end
        

%% END SCREEN: DISPLAY PAYOUT
Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
text = sprintf(['Thank you for completing the task, please wait for further instructions...']);
DrawFormattedText(expdata.windowPtr, text, 'center', 'center', expdata.colorText);
Screen(expdata.windowPtr, 'Flip');
WaitSecs(.5);


%% SAVE OUT DATA FROM EXPERIMENT
SaveWithoutOverwrite([expdata.fname], expdata);
KbWaitForKeys(expdata.keyExp, Inf);

if expdata.etSwitch == 1
    % Close eye tracking data file.
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    % Download eye tracking data file.
    try
        fprintf('Receiving data file ''%s''...\n', expdata.edfFile);
        status = Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
    catch
        save(['eyelink_file_error_' datestr(now, 30)]);
        fprintf('Problem receiving data file ''%s''\n', expdata.edfFile);
        psychrethrow(psychlasterror);
    end
end

CloseExperiment(expdata);








