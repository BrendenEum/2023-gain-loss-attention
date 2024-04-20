function expdata = OpenPTBScreen(expdata)
    if expdata.devScreen == true
        screenSize = [0 0 940 680];
        %screenSize = [0 0 1600 900];
    else
        screenSize = [];  % full screen
    end
    screens = Screen('Screens');
    screenNumber = max(screens);
    
    % Open a window with two buffers.
    nBuffers = 2;
    [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, ...
        [], screenSize, [], nBuffers);

    % Remove the blue screen flash and minimize extraneous warnings.
    if expdata.debug == true
        Screen('Preference', 'SkipSyncTests', 1);
        oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 4);
        oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 0);
    else
        Screen('Preference', 'SkipSyncTests', 0);
        oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
        oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
        priorityLevel = MaxPriority(windowPtr);
        Priority(priorityLevel);  % set maximum priority level
        HideCursor(windowPtr);
    end

    % Enable alpha blending, so that the tranparency layer of images gets used.
    Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    expdata.windowPtr = windowPtr;
    expdata.windowRect = windowRect;
    expdata.flipInterval = Screen('GetFlipInterval', expdata.windowPtr);

end