function DisplaySelectedTrial(SID,trialNum)
% DISPLAYSELECTEDTRIAL
% Purpose: This function takes a Subject's ID and a Trial Number and 
%          returns the WIN/LOSS Probabilites the Subject chose for the given trial
%
% Usage: DisplaySelectedTrial(SID,trialNum)
%
% Required input:  
% SID           -->     Subject Identification 
% trialNum      -->     Selected Trial Number 


    fileName = [pwd '/expdata/expdata_' num2str(SID) '.mat']; % Get the filename of the Subject's expdata
    load(fileName); % Load Subject's data
    

    winChoice = data.win_choice(trialNum);      % Choice made in given trial during the WIN block 
    lossChoice = data.loss_choice(trialNum);    % Choice made in given trial during the LOSS block
    
    % Print WIN Block Probability choice
    if winChoice == 1 % If chose LEFT
        fprintf('Selected Win: %d\n', data.win_StimProb_left(trialNum)); %Print Left Probability Stim
    elseif winChoice == 2 % If chose RIGHT
        fprintf('Selected Win: %d\n', data.win_StimProb_right(trialNum)); % Print Right Probability Stim
    end
    
    % Print LOSS Block Probability choice
    if lossChoice == 1 % If chose LEFT
        fprintf('Selected Loss: %d\n', data.loss_StimProb_left(trialNum)); %Print Left Probability Stim
    elseif lossChoice == 2 % If chose RIGHT
        fprintf('Selected Loss: %d\n', data.loss_StimProb_right(trialNum)); % Print Right Probability Stim
    end

end