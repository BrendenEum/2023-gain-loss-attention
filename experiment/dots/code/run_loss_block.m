function expdata = run_loss_block(expdata,eyeLink)
if expdata.etSwitch == 1
    % Print current BLOCK/TRIAL to ET screen
	Eyelink('Command', 'record_status_message "LOSS BLOCK %d, TRIAL %d"', expdata.curBlock, expdata.trialNum);
    
    
    %% DISPLAY FIXATION CROSS
    % Setup eye tracker for recording trial.
    message = sprintf('TRIALID T_%d', expdata.trialNum);
    Eyelink('Message', message);
    Eyelink('StartRecording');
    eyeUsed = Eyelink('EyeAvailable');
    
    DisplayFixationCross(expdata);
        
    % Make sure subject fixates on the cross for the required time.
    fixationTime = 0;
    fixStartTime = GetSecs;
    staticStartSecs = GetSecs;
    % WaitSecs(expdata.timeFixationScreen); % If eye-tracking is off
    while fixationTime < expdata.timeFixationScreen
        if Eyelink('NewFloatSampleAvailable') > 0 && ...
                GetSecs < staticStartSecs + 30
            % Get the sample in the form of an event structure.
            evt = Eyelink('NewestFloatSample');
            x = evt.gx(eyeUsed+1); % +1 because we're accessing a Matlab array
            y = evt.gy(eyeUsed+1);

            % Do we have valid data and is the pupil visible?
            if x ~= eyeLink.MISSING_DATA && y ~= eyeLink.MISSING_DATA && ...
                    evt.pa(eyeUsed+1) > 0
                xFix=x;
                yFix=y;

                if xFix > expdata.screenCenter(1)-100 && ...
                    xFix < expdata.screenCenter(1)+100 && ...
                    yFix > expdata.screenCenter(2)-100 && ...
                    yFix < expdata.screenCenter(2)+100
                    fixationTime =  GetSecs - fixStartTime;
                else
                    fixationTime = 0;
                    fixStartTime = GetSecs;
                end
            end
        elseif GetSecs >= staticStartSecs + 30
            fprintf(...
                'Failure in central fixation before TEST TRIAL %d.%d', ...
                expdata.curBlock, expdata.trialNum);
            Eyelink('Message', ...
                'Failure in central fixation before TEST TRIAL %d.%d', ...
                expdata.curBlock, expdata.trialNum);
            Eyelink('StopRecording');
            EyelinkDoTrackerSetup(eyeLink);
            fprintf(...
                'Restrarting central fixation before TEST TRIAL %d.%d', ...
                expdata.curBlock, expdata.trialNum);
            Eyelink('Message', ...
                'Restrarting central fixation before TEST TRIAL %d.%d', ...
                expdata.curBlock, expdata.trialNum);
            Eyelink('StartRecording');
            DisplayFixationCross(expdata);
            fixStartTime = GetSecs;
            staticStartSecs = GetSecs;
        end
    end
end

    %% BALL PROBABILITIES
    ball_prob = randsample(expdata.ballProb,2,true);
    
    % Assign Circle Probability values
    expdata.loss_StimProb_left(expdata.trialNum) = ball_prob(1);
    expdata.loss_StimProb_right(expdata.trialNum) = ball_prob(2);
    
    
    %% Left Stimuli
    % Draw Grey Circles
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);

    % Left Circle Containter
    my_circle(expdata.windowPtr, [],expdata.leftCircleCenterX,... 
        expdata.leftCircleCenterY,expdata.circleRadius,expdata.whiteCircle,expdata.circleContour); 
    
    % Generate 100 random cetners
    centers = generateCenters(expdata,1);
    
    % Draw Left Balls
    for ii = 1:ball_prob(1)
        my_circle(expdata.windowPtr, expdata.redCircle, centers(ii,1),...
                centers(ii,2),expdata.ballRadius);
    end
    
    for ii = ball_prob(1)+1:100
        my_circle(expdata.windowPtr, expdata.whiteCircle, centers(ii,1),...
                centers(ii,2),expdata.ballRadius);
    end
        
    %% Right Stimuli
    % Right Circle Containter
    my_circle(expdata.windowPtr, [],expdata.rightCircleCenterX,... 
        expdata.rightCircleCenterY,expdata.circleRadius,expdata.whiteCircle,expdata.circleContour);

    % Generate 100 random cetners
    centers = generateCenters(expdata,2);
    
    % Draw Right Balls
    for ii = 1:ball_prob(2)
        my_circle(expdata.windowPtr, expdata.redCircle, centers(ii,1),...
                centers(ii,2),expdata.ballRadius);
    end
    
    for ii = ball_prob(2)+1:100
        my_circle(expdata.windowPtr, expdata.whiteCircle, centers(ii,1),...
                centers(ii,2),expdata.ballRadius);
    end
    
if expdata.etSwitch == 1
    disp('Decision screen. Waiting for response...');
    Eyelink('Message', 'SYNCTIME'); % Sync time so we know where the decision screen begins.    
end
    Screen('Flip', expdata.windowPtr, 0, 1);


    [parResponded, responseTime, reactionTime, keyCode] = ...                     
            KbWaitForKeys(expdata.choiceKeysBinary, expdata.timeDecisionPhase);   %Wait for User input

        
    %% SAVEOUT DATA
    if parResponded == 1
        expdata.loss_RT(expdata.trialNum) = reactionTime;
        
        % If LEFT Response
        if keyCode(expdata.keyLeft)
            expdata.loss_choice(expdata.trialNum) = 1;
            
            % Present Selection Box
            my_square(expdata.windowPtr, expdata.colorBox, expdata.leftCircleCenterX, expdata.leftCircleCenterY,...
                    expdata.circleRadius*2 + 50, expdata.lineWidth);
                Screen('Flip',expdata.windowPtr);
                WaitSecs(expdata.timeSelectionBox); %0.5 Sec
        
        % If Right Response 
        elseif keyCode(expdata.keyRight)
            expdata.loss_choice(expdata.trialNum) = 2;
            
            %Present Selection Box
            my_square(expdata.windowPtr, expdata.colorBox, expdata.rightCircleCenterX, expdata.rightCircleCenterY,...
                    expdata.circleRadius*2 + 50, expdata.lineWidth);
                Screen('Flip',expdata.windowPtr);
                WaitSecs(expdata.timeSelectionBox); %0.5 Sec
        end
        if expdata.etSwitch == 1
            Eyelink('StopRecording');
            Eyelink('Message', 'TRIAL OK');
        end
    end

 %% DISPLAY BLANK SCREEN
    Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
    Screen(expdata.windowPtr, 'Flip');
    WaitSecs(1);


end
