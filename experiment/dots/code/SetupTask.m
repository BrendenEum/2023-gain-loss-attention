function expdata = SetupTask(SID)
%% ************************************************************************
%       EXPERIMENT DATA STRUCTURE
%**************************************************************************
expdata = struct();
expdata.currentDir = pwd;
expdata.dataDir = [pwd '/expdata/'];
mkdir(expdata.dataDir);
expdata.SID = SID;


%% ************************************************************************
%       PARTICIPANT INFORMATION
%**************************************************************************
expdata.fname = [expdata.dataDir 'expdata_' SID];


%% ************************************************************************
%       EXPERIMENT PARAMETERS
%**************************************************************************
expdata.numTrials_practice = 8;     % Number of practice trials
expdata.numTrials = 200;              % Number of trials

expdata.timeFixationScreen = .5;    % Time for fixation cross
expdata.timeDecisionPhase = Inf;    % Time Subject has to make a choice    
expdata.timeSelectionBox = 1;       % Time for Selection Box
expdata.timeRestBlank = 1;          % Time for Blank screen


%% ************************************************************************
%       BINARY SWITCHES
%**************************************************************************
%Set of Binary Switches used to switch between options for the task

%Screen Switch  
%1 = Windowed screen for development, 0 = Full Screen
expdata.devScreen = 1;              

%Switch for turning ON/OFF the practce trials
%(0 = OFF, 1 = ON) 
expdata.practiceSwitch = 1;    

%Switch for turing ON/OFF the Eye-Trackter code
expdata.etSwitch = 0;

expdata.debug = false;
        
%% ************************************************************************
%       EXPERIMENT DATA Structures
%**************************************************************************
expdata.win_StimProb_left =  NaN(1, expdata.numTrials);
expdata.win_StimProb_right=  NaN(1, expdata.numTrials);
expdata.win_choice =  NaN(1, expdata.numTrials);
expdata.win_RT =  NaN(1, expdata.numTrials);

expdata.loss_StimProb_left =  NaN(1, expdata.numTrials);
expdata.loss_StimProb_right =  NaN(1, expdata.numTrials);
expdata.loss_choice =  NaN(1, expdata.numTrials);
expdata.loss_RT =  NaN(1, expdata.numTrials);


%% ************************************************************************
%       INITIALIZE PTB
%**************************************************************************
expdata = OpenPTBScreen(expdata);

expdata.screenScale = expdata.windowRect(3)/1280;


%% ************************************************************************
%       DISPLAY PARAMETERS
%**************************************************************************
screenCenter = [floor((expdata.windowRect(1)+expdata.windowRect(3))/2) ...
    floor((expdata.windowRect(2)+expdata.windowRect(4))/2)];
screenCenterBot = [floor((expdata.windowRect(1)+expdata.windowRect(3))/2) ...
    floor(screenCenter(2)+(sqrt(3)/6)*expdata.windowRect(4))];
screenCenterTop = [floor((expdata.windowRect(1)+expdata.windowRect(3))/2) ...
    floor(screenCenter(2)-(sqrt(3)/6)*expdata.windowRect(4))];
expdata.screenCenter = screenCenter;
expdata.screenCenterBot = screenCenterBot;
expdata.screenCenterTop = screenCenterTop;

expdata.screenRight = [floor(screenCenter(1)+expdata.windowRect(3)/4) ...
    screenCenter(2)];
expdata.screenRightTop = [floor(screenCenter(1)+expdata.windowRect(3)/4) ...
    floor(screenCenter(2)-(sqrt(3)/6)*expdata.windowRect(4))];
expdata.screenRightBot = [floor(screenCenter(1)+expdata.windowRect(3)/4) ...
    floor(screenCenter(2)+(sqrt(3)/6)*expdata.windowRect(4))];

expdata.screenLeft = [floor(screenCenter(1)-expdata.windowRect(3)/4) ...
    screenCenter(2)];
expdata.screenLeftTop = [floor(screenCenter(1)-expdata.windowRect(3)/4) ...
    floor(screenCenter(2)-(sqrt(3)/6)*expdata.windowRect(4))];
expdata.screenLeftBot = [floor(screenCenter(1)-expdata.windowRect(3)/4) ...
    floor(screenCenter(2)+(sqrt(3)/6)*expdata.windowRect(4))];


%% ************************************************************************
%       COLORS
%**************************************************************************
white = WhiteIndex(expdata.windowPtr);
black = BlackIndex(expdata.windowPtr);
red = [255 0 0];
expdata.colorBackground = black;
expdata.colorText = white;
expdata.colorLine = white;
expdata.colorSlideBar = [192,192,192];
expdata.colorBox = red;
expdata.colorRestScreen = black;
expdata.greenCircle = [8 201 50];
expdata.whiteCircle = white;
expdata.redCircle = red;
expdata.greyCircle = [192,192,192];
Screen('FillRect', expdata.windowPtr, expdata.colorBackground);
Screen('TextColor', expdata.windowPtr, expdata.colorText); 


%% ************************************************************************
%       CIRCLE PARAMETERS 
%**************************************************************************
if expdata.devScreen == 1 % If using the development screen, than reduce the size of the stimulus by half
        expdata.circleRadius = 150; %Units in pixels
else
    expdata.circleRadius = 300;
end

expdata.circleBuffer = expdata.circleRadius * .10;
expdata.circleContour = 1;

% Circle Centers
% Center coordinates for the Cirlce Containers
expdata.leftCircleCenterX = expdata.screenLeft(1);
expdata.leftCircleCenterY = expdata.screenCenter(2);
expdata.rightCircleCenterX = expdata.screenRight(1);
expdata.rightCircleCenterY = expdata.screenCenter(2);

% Circle Ranges 
% Ranges used to randomly generate X & Y coordinates for
% ball centers so that they are drawn within the Boundary of the Circle Containers
expdata.leftCircleRangeX = [(expdata.leftCircleCenterX - expdata.circleRadius) + 10 ...
                                (expdata.leftCircleCenterX + expdata.circleRadius) - 10];     
expdata.leftCircleRangeY = [(expdata.leftCircleCenterY - expdata.circleRadius) + 10 ...
                                (expdata.leftCircleCenterY + expdata.circleRadius) - 10];
expdata.rightCircleRangeX = [(expdata.rightCircleCenterX - expdata.circleRadius) + 10 ...
                                (expdata.rightCircleCenterX + expdata.circleRadius) - 10];
expdata.rightCircleRangeY = [(expdata.rightCircleCenterY - expdata.circleRadius) + 10 ...
                                (expdata.rightCircleCenterY + expdata.circleRadius) - 10];


expdata.ballProb = (45:55);                                             % Probability of Balls for trial stimuli

expdata.ballRadius = round(expdata.circleRadius*.033);                  % Ball Radius

expdata.ballBuffer = (expdata.ballRadius * 2) + 2;                      % Buffer between balls so they do not overlap
expdata.containterBoundary = expdata.circleRadius - expdata.ballRadius; % Boundary of containters, so balls are drawn within the Circle Containter




%% ************************************************************************
%       SHAPES
%**************************************************************************
expdata.crossSize = 50;
expdata.lineWidth = 3;
expdata.barLength = 80;
expdata.barWidth = 4;
expdata.boxSize = 190;


%% ************************************************************************
%       TEXT
%**************************************************************************
expdata.textSize = ceil(20*expdata.screenScale);
expdata.textFont = 'Arial';
Screen('TextFont', expdata.windowPtr, expdata.textFont);
Screen('TextSize', expdata.windowPtr, expdata.textSize);


%% ************************************************************************
%       KEYBOARD
%**************************************************************************
% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems.
KbName('UnifyKeyNames');
expdata.keySpace = KbName('space');
expdata.keyLeft = KbName('LeftArrow'); % A
expdata.keyRight = KbName('RightArrow'); % L
expdata.keyMiddle = KbName('UpArrow'); % G
expdata.keyMiddle2 = KbName('DownArrow');
expdata.keyExp = KbName('e');
expdata.choiceKeysBinary = [expdata.keyLeft expdata.keyRight];
end
