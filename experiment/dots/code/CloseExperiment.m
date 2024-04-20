function CloseExperiment(expdata)
% Function:
%	Closes PTB screen, returns priority to 0, starts the update process,
%   and shows the cursor.
%
% Args:
%   None
%
% Returns:
%	Nothing
if expdata.etSwitch == 1
    Eyelink('Shutdown');
end

Screen('Preference','SkipSyncTests',0);
Priority(0);
Screen('CloseAll');
ShowCursor; % Show cursor again, if it has been disabled.
    
end