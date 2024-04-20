function [fixTime, fixLocX, fixLocY, fixItem, fixPupArea, trialDuration,transitionTime, mergedBlankFixations, RawFixTime, RawFixLocX, RawFixLocY, RawFixItem,RawFixPupArea, rawXSamples, rawYSamples, rawTimeStampSamples, rawPupAreaSamples, rawItemSamples,potentiallyBadTrials, data] = ReadFixations(SID,data,block_type)

    % This function classifies saccades as blank fixations. In addition,
    % consecutive fixations on the same item are grouped together into the same
    % fixation. Only the x and y coordinates of the first fixation in that series are stored.

    tic
    %% Read file with eye tracking data
    if strcmp(block_type, 'win')
        fileName = ['~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data/' num2str(SID) '/' num2str(SID) '_win.asc'];
        fileIdEye = fopen(fileName, 'r');
    
    elseif strcmp(block_type, 'los')
        fileName = ['~/Documents/a_Tasks_Experiments/aDDM_win_loss_lottery/data/pilot_data/' num2str(SID) '/' num2str(SID) '_los.asc'];
        fileIdEye = fopen(fileName, 'r');
    end


    %% Initialize eye tracking data arrays.
    fixTime = cell(1,data.numTrials);
    fixLocX = cell(1,data.numTrials);
    fixLocY = cell(1,data.numTrials);
    fixItem = cell(1,data.numTrials);
    fixPupArea = cell(1,data.numTrials);
    trialDuration = zeros(1,data.numTrials);
    transitionTime = zeros(1,data.numTrials);

    % Keep track of all "fixations" not consolidated
    RawFixTime = cell(1,data.numTrials);
    RawFixLocX = cell(1,data.numTrials);
    RawFixLocY = cell(1,data.numTrials);
    RawFixItem = cell(1,data.numTrials);
    RawFixPupArea = cell(1,data.numTrials);
    rawXSamples = cell(1,data.numTrials);
    rawYSamples = cell(1,data.numTrials);
    rawPupAreaSamples = cell(1,data.numTrials);
    rawTimeStampSamples = cell(1,data.numTrials);
    rawItemSamples = cell(1,data.numTrials);
    mergedBlankFixations = [];
    potentiallyBadTrials = [];


    %% PARSE DATA FROM EYE TRACKING FILE.
    
    for trialNum = 1:data.numTrials
       
        % Find the start of this trial's data.
        trialString = sprintf('TRIALID T_%d', trialNum);   %Assign target string to search for, Looking for the Trial Number.
        while true
            line = fgetl(fileIdEye);                       %Read next line from file 
            if strfind(line, trialString)                  %If target string is found, end loop 
                break;
            end
        end

        % Find the sync time message for this trial. (Where the decision screen begins)
        while true
            line = fgetl(fileIdEye);                        %Read next line from file 
            if strfind(line, 'SYNCTIME')                    %If line contains 'SYNCTIME' end loop 
                res = sscanf(line,'%*s %d');                %Save the time in miliseconds from the 'SYNCTIME' line
                firstFixStartTime = res(1);                 %Assign the Start time of first fixation. (Where the decision screen begins)
                break;
            end
        end
        %% Get all the fixation and saccade events for this trial
        % Note: saccades are classified the same as fixations on blank
        % locations (i.e. not left, right or center), and have fixLockX and 
        % fixLocY set to -1.
        isFirstFix = true;
        eventNum = 1;
        rawNum = 1;
        decisionTime = 0; % Time spent looking at stimuli
        totalTime = 0;    % Total time spent looking around on the trial (including blank fixations)
        numSamples = 1;   %Sample Counter
        
        while true
            line = fgetl(fileIdEye);
            if strfind(line, 'EFIX') %#ok<*STRIFCND>
                res = sscanf(line,'%*s %*s %d %d %d %f %f %f', 6);
                fixStartTime = res(1);
                fixEndTime = res(2);
                time = res(3);
                xPos = res(4);
                yPos = res(5);
                pArea = res(6);
                
                item = GetItem(xPos, yPos, data, isFirstFix);
                
                % Initial central fixation. 
                if isFirstFix
                    isFirstFix = false;
                    time = fixEndTime - firstFixStartTime;
                    fixTime{trialNum}(eventNum) = time;
                    fixLocX{trialNum}(eventNum) = xPos;
                    fixLocY{trialNum}(eventNum) = yPos;
                    fixItem{trialNum}(eventNum) = item;
                    fixPupArea{trialNum}(eventNum) = pArea;
                    eventNum = eventNum + 1;
                    
                elseif eventNum > 1 && item == fixItem{trialNum}(eventNum-1)                    
                % If still looking at same item as previous fixation, 
                % consolidate into the same fixation (dumps extra x,y coordinates),
                % probably okay to do this since we only care about which item is being looked at?
                    
                    fixTime{trialNum}(eventNum-1) = fixTime{trialNum}(eventNum-1) + time;
                    
                else
                    fixTime{trialNum}(eventNum) = time;
                    fixLocX{trialNum}(eventNum) = xPos;
                    fixLocY{trialNum}(eventNum) = yPos;
                    fixItem{trialNum}(eventNum) = item;
                    fixPupArea{trialNum}(eventNum) = pArea;
                    
                    eventNum= eventNum + 1;
                end
                totalTime = totalTime + time;
                
                % Same as fixItem, etc. but does not consolidate "same item"
                % fixations into the same data point
                RawFixTime{trialNum}(rawNum) = time;
                RawFixLocX{trialNum}(rawNum) = xPos;
                RawFixLocY{trialNum}(rawNum) = yPos;
                RawFixItem{trialNum}(rawNum) = item;
                RawFixPupArea{trialNum}(rawNum) = pArea;
                rawNum = rawNum + 1;     
                
                % If fixation was on an item, add duration to decision time
                if item == 1 || item == 2
                    decisionTime = decisionTime + time;
                end
            elseif strfind(line, 'ESACC')
                res = sscanf(line,'%*s %*s %*d %*d %d', 1);
                time = res(1);   
                
                if eventNum > 1 && fixItem{trialNum}(eventNum-1) == 4
                    % This sets a saccade after a blank fixation to just be 
                    % part of that fixation -> distinction not important
                    fixTime{trialNum}(eventNum-1) = fixTime{trialNum}(eventNum-1) + time;
                else
                    % Treat saccade as blank fixations
                    fixTime{trialNum}(eventNum) = time;
                    fixLocX{trialNum}(eventNum) = -1;
                    fixLocY{trialNum}(eventNum) = -1;
                    fixItem{trialNum}(eventNum) = 0;
                    fixPupArea{trialNum}(eventNum) = -1;
                    eventNum = eventNum + 1;
                end
                RawFixTime{trialNum}(rawNum) = time;
                RawFixLocX{trialNum}(rawNum) = -1;
                RawFixLocY{trialNum}(rawNum) = -1;
                RawFixItem{trialNum}(rawNum) = 0;
                RawFixPupArea{trialNum}(rawNum) = -1;
                rawNum = rawNum + 1;

                totalTime = totalTime + time;
                
            elseif any(strfind(line, 'END'))
                trialDuration(trialNum) = totalTime;
                transitionTime(trialNum) = ...
                    totalTime - decisionTime;
                % transition time is the time not spent looking at items
                break;
            elseif ismember(line(1),'1234567890') % Check if its a sample line
                %Efficiency is sacrificed in order to identify bad data
                % Option 1
%                 res = textscan(line,'%s');
%                 res = res{1};
%                 time = str2double(res{1}) - firstFixStartTime;
%                 pArea = str2double(res{4});
%                 xPos = str2double(res{2});
%                 yPos = str2double(res{3});
                % Option 2
                res = sscanf(line,'%f %*s %*s %f', 2);
                time = res(1) - firstFixStartTime;
                pArea = res(2);
                res = sscanf(line,'%*s %s %*s %*s', 1);
                xPos = str2double(res);
                res = sscanf(line,'%*s %*s %s %*s', 1);
                yPos = str2double(res);
            
                % If data is outside screen coordinates, or missing -> Set NaN
                if isnan(xPos) || isnan(yPos) || xPos > data.windowRect(3) || xPos < data.windowRect(1) || yPos > data.windowRect(4) || yPos < data.windowRect(2)
                    item = 0;
                    xPos = NaN;
                    yPos = NaN;
                else
                    item = GetItem(xPos, yPos, data, false);
                end
                rawXSamples{trialNum}(numSamples) = xPos;
                rawYSamples{trialNum}(numSamples) = yPos;
                rawPupAreaSamples{trialNum}(numSamples) = pArea;
                rawTimeStampSamples{trialNum}(numSamples) = time;
                rawItemSamples{trialNum}(numSamples) = item;
                numSamples = numSamples + 1;
            end
        end % end of trial
        %% Transform a middle or blank fixation into an item fixation if it is sandwiched between 2 fixations to the same item.
        trialFixItems = [];
        trialFixTimes = [];
        fix = 1;
        for i = 1:length(fixItem{trialNum})
            %Item fixations.
            if fixItem{trialNum}(i) == 1 || fixItem{trialNum}(i) == 2 
                if fix > 1 && trialFixItems(fix-1) == fixItem{trialNum}(i)
                    trialFixTimes(fix-1) = ...
                        trialFixTimes(fix-1) + ...
                        fixTime{trialNum}(i);
                else
                    trialFixItems(fix) = ...
                        fixItem{trialNum}(i);
                    trialFixTimes(fix) = ...
                        fixTime{trialNum}(i);
                    fix = fix + 1;
                end
            %Blank or middle fixaitons, sandwiched. 
            elseif fix > 1 && i < length(fixItem{trialNum}) ...
                    && (trialFixItems(fix-1) == 1 || trialFixItems(fix-1) == 2) ... 
                    && trialFixItems(fix-1) == fixItem{trialNum}(i+1)
            
                trialFixTimes(fix-1) = trialFixTimes(fix-1) + fixTime{trialNum}(i);
                mergedBlankFixations = [mergedBlankFixations; fixTime{trialNum}(i)];
            % Blank or middle fixations, non-sandwiched.
            else
                trialFixItems(fix) = fixItem{trialNum}(i);
                trialFixTimes(fix) = fixTime{trialNum}(i);
                fix = fix + 1;
            end
        end
        fixTime{trialNum} = trialFixTimes;
        fixItem{trialNum} = trialFixItems;
    
        % Check if first fixation is on the center
        if rawItemSamples{trialNum}(1)~=3
            potentialyBadTrials = [potentiallyBadTrials trialNum];
        end
    end
    toc
end
























