#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy3 Experiment Builder (v2023.1.3),
    on June 22, 2023, at 16:49
If you publish work using this script the most relevant publication is:

    Peirce J, Gray JR, Simpson S, MacAskill M, Höchenberger R, Sogo H, Kastman E, Lindeløv JK. (2019) 
        PsychoPy2: Experiments in behavior made easy Behav Res 51: 195. 
        https://doi.org/10.3758/s13428-018-01193-y

"""

import psychopy
psychopy.useVersion('2023.1.3')


# --- Import packages ---
from psychopy import locale_setup
from psychopy import prefs
from psychopy import plugins
plugins.activatePlugins()
prefs.hardware['audioLib'] = 'ptb'
from psychopy import sound, gui, visual, core, data, event, logging, clock, colors, layout, iohub, hardware
from psychopy.tools import environmenttools
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)

import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle, choice as randchoice
import os  # handy system and path functions
import sys  # to get file system encoding

import psychopy.iohub as io
from psychopy.hardware import keyboard



# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)
# Store info about the experiment session
psychopyVersion = '2023.1.3'
expName = 'GainLossTask'  # from the Builder filename that created this script
expInfo = {
    'participant': f"{randint(0, 999):03.0f}",
    'block': ['1', '2'],
    'condition': ['gain','loss'],
}
# --- Show participant info dialog --
dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
if dlg.OK == False:
    core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
expInfo['psychopyVersion'] = psychopyVersion

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + u'data/%s_%s_%s' % (expInfo['participant'], expName, expInfo['date'])

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath='D:\\OneDrive - California Institute of Technology\\PhD\\Rangel Lab\\2023-gain-loss-attention\\numeric\\experiment\\code\\GainLossTask_lastrun.py',
    savePickle=True, saveWideText=True,
    dataFileName=filename)
# save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp
frameTolerance = 0.001  # how close to onset before 'same' frame

# Start Code - component code to be run after the window creation

# --- Setup the Window ---
win = visual.Window(
    size=[1920, 1080], fullscr=True, screen=0, 
    winType='pyglet', allowStencil=False,
    monitor='testMonitor', color=[-1.0000, -1.0000, -1.0000], colorSpace='rgb',
    backgroundImage='', backgroundFit='none',
    blendMode='avg', useFBO=True, 
    units='height')
win.mouseVisible = False
# store frame rate of monitor if we can measure it
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0  # could not measure, so guess
# --- Setup input devices ---
ioConfig = {}

# Setup eyetracking
ioConfig['eyetracker.hw.sr_research.eyelink.EyeTracker'] = {
    'name': 'tracker',
    'model_name': 'EYELINK 1000 DESKTOP',
    'simulation_mode': False,
    'network_settings': '100.1.1.1',
    'default_native_data_file_name': 'EXPFILE',
    'runtime_settings': {
        'sampling_rate': 250.0,
        'track_eyes': 'LEFT_EYE',
        'sample_filtering': {
            'sample_filtering': 'FILTER_LEVEL_2',
            'elLiveFiltering': 'FILTER_LEVEL_OFF',
        },
        'vog_settings': {
            'pupil_measure_types': 'PUPIL_DIAMETER',
            'tracking_mode': 'PUPIL_CR_TRACKING',
            'pupil_center_algorithm': 'ELLIPSE_FIT',
        }
    }
}

# Setup iohub keyboard
ioConfig['Keyboard'] = dict(use_keymap='psychopy')

ioSession = '1'
if 'session' in expInfo:
    ioSession = str(expInfo['session'])
ioServer = io.launchHubServer(window=win, experiment_code='GainLossTask', session_code=ioSession, datastore_name=filename, **ioConfig)
eyetracker = ioServer.getDevice('tracker')

# create a default keyboard (e.g. to check for escape)
defaultKeyboard = keyboard.Keyboard(backend='iohub')

# --- Initialize components for Routine "InitialCode" ---
# Run 'Begin Experiment' code from InitialCodeCode
# Some details about the experiment.

TrialNumber = 1 # Send messages to the eyetracker with trial number.
MaxDecisionTime = 10 # How long do subjects have to make a choice?

# Set FasterColor to black for now. Changes at Choice Routine.

FasterColor = "black"

# Experiment Settings

Condition = expInfo['condition']
Block = int(expInfo['block'])

# --- Initialize components for Routine "Welcome" ---
WelcomeText = visual.TextStim(win=win, name='WelcomeText',
    text="Welcome! \n\nThe experimenter will hand you a paper with instructions on them. Please read them carefully!\n\nIf this is your second block of trials, you can simply continue.\n\nPress 'Down Arrow' once you're done with the instructions and your experimenter has answered all your questions.",
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
WelcomeResponse = keyboard.Keyboard()

# --- Initialize components for Routine "PracticeBegin" ---
PracticeText = visual.TextStim(win=win, name='PracticeText',
    text="Practice.\n\nFirst, we will pratice 12 trials without the eye-tracker. \n\nWhen ready, press 'Down Arrow' to begin.",
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
PracticeResponse = keyboard.Keyboard()

# --- Initialize components for Routine "FixationCross" ---
FixationCrossPolygon = visual.ShapeStim(
    win=win, name='FixationCrossPolygon', vertices='cross',
    size=[.05,.05],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor='white', fillColor='white',
    opacity=None, depth=-1.0, interpolate=True)

# --- Initialize components for Routine "Choice" ---
LAmtText = visual.TextStim(win=win, name='LAmtText',
    text='',
    font='Open Sans',
    pos=(-.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
LProbText = visual.TextStim(win=win, name='LProbText',
    text='',
    font='Open Sans',
    pos=(-.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-2.0);
RAmtText = visual.TextStim(win=win, name='RAmtText',
    text='',
    font='Open Sans',
    pos=(.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-3.0);
RProbText = visual.TextStim(win=win, name='RProbText',
    text='',
    font='Open Sans',
    pos=(.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-4.0);
Response = keyboard.Keyboard()
Divider = visual.Rect(
    win=win, name='Divider',
    width=[.005, .75][0], height=[.005, .75][1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor=[0.0039, 0.0039, 0.0039], fillColor=[0.0039, 0.0039, 0.0039],
    opacity=None, depth=-6.0, interpolate=True)

# --- Initialize components for Routine "Feedback" ---
LAmtText_2 = visual.TextStim(win=win, name='LAmtText_2',
    text='',
    font='Open Sans',
    pos=(-.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
LProbText_2 = visual.TextStim(win=win, name='LProbText_2',
    text='',
    font='Open Sans',
    pos=(-.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-2.0);
RAmtText_2 = visual.TextStim(win=win, name='RAmtText_2',
    text='',
    font='Open Sans',
    pos=(.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-3.0);
RProbText_2 = visual.TextStim(win=win, name='RProbText_2',
    text='',
    font='Open Sans',
    pos=(.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-4.0);
FeedbackRectangle = visual.Rect(
    win=win, name='FeedbackRectangle',
    width=(0.5, 0.75)[0], height=(0.5, 0.75)[1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=12.0,     colorSpace='rgb',  lineColor='white', fillColor=None,
    opacity=None, depth=-5.0, interpolate=True)
Divider_2 = visual.Rect(
    win=win, name='Divider_2',
    width=[.005, .75][0], height=[.005, .75][1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor=[0.0039, 0.0039, 0.0039], fillColor=[0.0039, 0.0039, 0.0039],
    opacity=None, depth=-6.0, interpolate=True)

# --- Initialize components for Routine "ITI" ---
ITIText = visual.TextStim(win=win, name='ITIText',
    text='',
    font='Open Sans',
    pos=(0, 0), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);

# --- Initialize components for Routine "ExperimentBegin" ---
ExperimentBeginText = visual.TextStim(win=win, name='ExperimentBeginText',
    text="Practice complete. Nice job!\n\nReady to begin the real experiment? Press 'Down Arrow' when you're ready to start.",
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
ExperimentBeginResp = keyboard.Keyboard()

# --- Initialize components for Routine "StartBlock1" ---
StartBlockText = visual.TextStim(win=win, name='StartBlockText',
    text="Starting Block 1 of 2.\n\nThis block has 100 trials. Please stay as still as possible during the trials. You'll be able to take a break and stretch after!\n\nWhen ready, press 'Down Arrow' to begin.",
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=0.0);
key_resp = keyboard.Keyboard()

# --- Initialize components for Routine "FixationCross" ---
FixationCrossPolygon = visual.ShapeStim(
    win=win, name='FixationCrossPolygon', vertices='cross',
    size=[.05,.05],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor='white', fillColor='white',
    opacity=None, depth=-1.0, interpolate=True)

# --- Initialize components for Routine "Choice" ---
LAmtText = visual.TextStim(win=win, name='LAmtText',
    text='',
    font='Open Sans',
    pos=(-.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
LProbText = visual.TextStim(win=win, name='LProbText',
    text='',
    font='Open Sans',
    pos=(-.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-2.0);
RAmtText = visual.TextStim(win=win, name='RAmtText',
    text='',
    font='Open Sans',
    pos=(.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-3.0);
RProbText = visual.TextStim(win=win, name='RProbText',
    text='',
    font='Open Sans',
    pos=(.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-4.0);
Response = keyboard.Keyboard()
Divider = visual.Rect(
    win=win, name='Divider',
    width=[.005, .75][0], height=[.005, .75][1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor=[0.0039, 0.0039, 0.0039], fillColor=[0.0039, 0.0039, 0.0039],
    opacity=None, depth=-6.0, interpolate=True)

# --- Initialize components for Routine "Feedback" ---
LAmtText_2 = visual.TextStim(win=win, name='LAmtText_2',
    text='',
    font='Open Sans',
    pos=(-.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
LProbText_2 = visual.TextStim(win=win, name='LProbText_2',
    text='',
    font='Open Sans',
    pos=(-.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-2.0);
RAmtText_2 = visual.TextStim(win=win, name='RAmtText_2',
    text='',
    font='Open Sans',
    pos=(.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-3.0);
RProbText_2 = visual.TextStim(win=win, name='RProbText_2',
    text='',
    font='Open Sans',
    pos=(.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-4.0);
FeedbackRectangle = visual.Rect(
    win=win, name='FeedbackRectangle',
    width=(0.5, 0.75)[0], height=(0.5, 0.75)[1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=12.0,     colorSpace='rgb',  lineColor='white', fillColor=None,
    opacity=None, depth=-5.0, interpolate=True)
Divider_2 = visual.Rect(
    win=win, name='Divider_2',
    width=[.005, .75][0], height=[.005, .75][1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor=[0.0039, 0.0039, 0.0039], fillColor=[0.0039, 0.0039, 0.0039],
    opacity=None, depth=-6.0, interpolate=True)

# --- Initialize components for Routine "ITI" ---
ITIText = visual.TextStim(win=win, name='ITIText',
    text='',
    font='Open Sans',
    pos=(0, 0), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);

# --- Initialize components for Routine "EndBlock1" ---
EndBlock1Text = visual.TextStim(win=win, name='EndBlock1Text',
    text='',
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=0.0);
EndBlock1Response = keyboard.Keyboard()

# --- Initialize components for Routine "StartBlock2" ---
StartBlockText_2 = visual.TextStim(win=win, name='StartBlockText_2',
    text="Starting Block 2 of 2.\n\nThis block has 100 trials. Please stay as still as possible during the trials. You'll be able to take a break and stretch after!\n\nWhen ready, press 'Down Arrow' to begin.",
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=0.0);
key_resp_2 = keyboard.Keyboard()

# --- Initialize components for Routine "FixationCross" ---
FixationCrossPolygon = visual.ShapeStim(
    win=win, name='FixationCrossPolygon', vertices='cross',
    size=[.05,.05],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor='white', fillColor='white',
    opacity=None, depth=-1.0, interpolate=True)

# --- Initialize components for Routine "Choice" ---
LAmtText = visual.TextStim(win=win, name='LAmtText',
    text='',
    font='Open Sans',
    pos=(-.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
LProbText = visual.TextStim(win=win, name='LProbText',
    text='',
    font='Open Sans',
    pos=(-.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-2.0);
RAmtText = visual.TextStim(win=win, name='RAmtText',
    text='',
    font='Open Sans',
    pos=(.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-3.0);
RProbText = visual.TextStim(win=win, name='RProbText',
    text='',
    font='Open Sans',
    pos=(.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-4.0);
Response = keyboard.Keyboard()
Divider = visual.Rect(
    win=win, name='Divider',
    width=[.005, .75][0], height=[.005, .75][1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor=[0.0039, 0.0039, 0.0039], fillColor=[0.0039, 0.0039, 0.0039],
    opacity=None, depth=-6.0, interpolate=True)

# --- Initialize components for Routine "Feedback" ---
LAmtText_2 = visual.TextStim(win=win, name='LAmtText_2',
    text='',
    font='Open Sans',
    pos=(-.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);
LProbText_2 = visual.TextStim(win=win, name='LProbText_2',
    text='',
    font='Open Sans',
    pos=(-.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-2.0);
RAmtText_2 = visual.TextStim(win=win, name='RAmtText_2',
    text='',
    font='Open Sans',
    pos=(.5, .15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-3.0);
RProbText_2 = visual.TextStim(win=win, name='RProbText_2',
    text='',
    font='Open Sans',
    pos=(.5, -.15), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-4.0);
FeedbackRectangle = visual.Rect(
    win=win, name='FeedbackRectangle',
    width=(0.5, 0.75)[0], height=(0.5, 0.75)[1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=12.0,     colorSpace='rgb',  lineColor='white', fillColor=None,
    opacity=None, depth=-5.0, interpolate=True)
Divider_2 = visual.Rect(
    win=win, name='Divider_2',
    width=[.005, .75][0], height=[.005, .75][1],
    ori=0.0, pos=[0,0], anchor='center',
    lineWidth=1.0,     colorSpace='rgb',  lineColor=[0.0039, 0.0039, 0.0039], fillColor=[0.0039, 0.0039, 0.0039],
    opacity=None, depth=-6.0, interpolate=True)

# --- Initialize components for Routine "ITI" ---
ITIText = visual.TextStim(win=win, name='ITIText',
    text='',
    font='Open Sans',
    pos=(0, 0), height=0.1, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=-1.0);

# --- Initialize components for Routine "EndBlock2" ---
EndBlock2Text = visual.TextStim(win=win, name='EndBlock2Text',
    text='',
    font='Open Sans',
    pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
    color='white', colorSpace='rgb', opacity=None, 
    languageStyle='LTR',
    depth=0.0);
EndBlock2Response = keyboard.Keyboard()

# --- Initialize components for Routine "EndCode" ---

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.Clock()  # to track time remaining of each (possibly non-slip) routine 

# --- Prepare to start Routine "InitialCode" ---
continueRoutine = True
# update component parameters for each repeat
# keep track of which components have finished
InitialCodeComponents = []
for thisComponent in InitialCodeComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "InitialCode" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in InitialCodeComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "InitialCode" ---
for thisComponent in InitialCodeComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# the Routine "InitialCode" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# --- Prepare to start Routine "Welcome" ---
continueRoutine = True
# update component parameters for each repeat
# Run 'Begin Routine' code from WelcomeCode
# Indicator for Practice Trials

Practice = 1
WelcomeResponse.keys = []
WelcomeResponse.rt = []
_WelcomeResponse_allKeys = []
# keep track of which components have finished
WelcomeComponents = [WelcomeText, WelcomeResponse]
for thisComponent in WelcomeComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "Welcome" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *WelcomeText* updates
    
    # if WelcomeText is starting this frame...
    if WelcomeText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        WelcomeText.frameNStart = frameN  # exact frame index
        WelcomeText.tStart = t  # local t and not account for scr refresh
        WelcomeText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(WelcomeText, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'WelcomeText.started')
        # update status
        WelcomeText.status = STARTED
        WelcomeText.setAutoDraw(True)
    
    # if WelcomeText is active this frame...
    if WelcomeText.status == STARTED:
        # update params
        pass
    
    # *WelcomeResponse* updates
    waitOnFlip = False
    
    # if WelcomeResponse is starting this frame...
    if WelcomeResponse.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        WelcomeResponse.frameNStart = frameN  # exact frame index
        WelcomeResponse.tStart = t  # local t and not account for scr refresh
        WelcomeResponse.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(WelcomeResponse, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'WelcomeResponse.started')
        # update status
        WelcomeResponse.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(WelcomeResponse.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(WelcomeResponse.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if WelcomeResponse.status == STARTED and not waitOnFlip:
        theseKeys = WelcomeResponse.getKeys(keyList=['down'], waitRelease=False)
        _WelcomeResponse_allKeys.extend(theseKeys)
        if len(_WelcomeResponse_allKeys):
            WelcomeResponse.keys = _WelcomeResponse_allKeys[-1].name  # just the last key pressed
            WelcomeResponse.rt = _WelcomeResponse_allKeys[-1].rt
            WelcomeResponse.duration = _WelcomeResponse_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in WelcomeComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "Welcome" ---
for thisComponent in WelcomeComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if WelcomeResponse.keys in ['', [], None]:  # No response was made
    WelcomeResponse.keys = None
thisExp.addData('WelcomeResponse.keys',WelcomeResponse.keys)
if WelcomeResponse.keys != None:  # we had a response
    thisExp.addData('WelcomeResponse.rt', WelcomeResponse.rt)
    thisExp.addData('WelcomeResponse.duration', WelcomeResponse.duration)
thisExp.nextEntry()
# the Routine "Welcome" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# --- Prepare to start Routine "PracticeBegin" ---
continueRoutine = True
# update component parameters for each repeat
# Run 'Begin Routine' code from PracticeBeginCode
if Block == 2:
    continueRoutine = False
PracticeResponse.keys = []
PracticeResponse.rt = []
_PracticeResponse_allKeys = []
# keep track of which components have finished
PracticeBeginComponents = [PracticeText, PracticeResponse]
for thisComponent in PracticeBeginComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "PracticeBegin" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *PracticeText* updates
    
    # if PracticeText is starting this frame...
    if PracticeText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        PracticeText.frameNStart = frameN  # exact frame index
        PracticeText.tStart = t  # local t and not account for scr refresh
        PracticeText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(PracticeText, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'PracticeText.started')
        # update status
        PracticeText.status = STARTED
        PracticeText.setAutoDraw(True)
    
    # if PracticeText is active this frame...
    if PracticeText.status == STARTED:
        # update params
        pass
    
    # *PracticeResponse* updates
    waitOnFlip = False
    
    # if PracticeResponse is starting this frame...
    if PracticeResponse.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        PracticeResponse.frameNStart = frameN  # exact frame index
        PracticeResponse.tStart = t  # local t and not account for scr refresh
        PracticeResponse.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(PracticeResponse, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'PracticeResponse.started')
        # update status
        PracticeResponse.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(PracticeResponse.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(PracticeResponse.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if PracticeResponse.status == STARTED and not waitOnFlip:
        theseKeys = PracticeResponse.getKeys(keyList=['down'], waitRelease=False)
        _PracticeResponse_allKeys.extend(theseKeys)
        if len(_PracticeResponse_allKeys):
            PracticeResponse.keys = _PracticeResponse_allKeys[-1].name  # just the last key pressed
            PracticeResponse.rt = _PracticeResponse_allKeys[-1].rt
            PracticeResponse.duration = _PracticeResponse_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in PracticeBeginComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "PracticeBegin" ---
for thisComponent in PracticeBeginComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if PracticeResponse.keys in ['', [], None]:  # No response was made
    PracticeResponse.keys = None
thisExp.addData('PracticeResponse.keys',PracticeResponse.keys)
if PracticeResponse.keys != None:  # we had a response
    thisExp.addData('PracticeResponse.rt', PracticeResponse.rt)
    thisExp.addData('PracticeResponse.duration', PracticeResponse.duration)
thisExp.nextEntry()
# the Routine "PracticeBegin" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
Practice = data.TrialHandler(nReps=1.0, method='random', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('spreadsheet_practice.csv'),
    seed=4, name='Practice')
thisExp.addLoop(Practice)  # add the loop to the experiment
thisPractice = Practice.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisPractice.rgb)
if thisPractice != None:
    for paramName in thisPractice:
        exec('{} = thisPractice[paramName]'.format(paramName))

for thisPractice in Practice:
    currentLoop = Practice
    # abbreviate parameter names if possible (e.g. rgb = thisPractice.rgb)
    if thisPractice != None:
        for paramName in thisPractice:
            exec('{} = thisPractice[paramName]'.format(paramName))
    
    # --- Prepare to start Routine "FixationCross" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from FixationCrossCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Turn on eyetracking
    eyetracker.setRecordingState(True)
    FixationCrossPolygon.setPos(FixCrossLoc)
    # keep track of which components have finished
    FixationCrossComponents = [FixationCrossPolygon]
    for thisComponent in FixationCrossComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "FixationCross" ---
    routineForceEnded = not continueRoutine
    while continueRoutine and routineTimer.getTime() < 0.5:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *FixationCrossPolygon* updates
        
        # if FixationCrossPolygon is starting this frame...
        if FixationCrossPolygon.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            FixationCrossPolygon.frameNStart = frameN  # exact frame index
            FixationCrossPolygon.tStart = t  # local t and not account for scr refresh
            FixationCrossPolygon.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(FixationCrossPolygon, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'FixationCrossPolygon.started')
            # update status
            FixationCrossPolygon.status = STARTED
            FixationCrossPolygon.setAutoDraw(True)
        
        # if FixationCrossPolygon is active this frame...
        if FixationCrossPolygon.status == STARTED:
            # update params
            pass
        
        # if FixationCrossPolygon is stopping this frame...
        if FixationCrossPolygon.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > FixationCrossPolygon.tStartRefresh + .5-frameTolerance:
                # keep track of stop time/frame for later
                FixationCrossPolygon.tStop = t  # not accounting for scr refresh
                FixationCrossPolygon.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'FixationCrossPolygon.stopped')
                # update status
                FixationCrossPolygon.status = FINISHED
                FixationCrossPolygon.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in FixationCrossComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "FixationCross" ---
    for thisComponent in FixationCrossComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-0.500000)
    
    # --- Prepare to start Routine "Choice" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from ChoiceCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Tell the eyetracker what trial this is.
    
    eyetracker.sendMessage("TRIALSTART "+str(TrialNumber))
    LAmtText.setColor(TextColor, colorSpace='rgb')
    LAmtText.setText(LAmt)
    LProbText.setColor(TextColor, colorSpace='rgb')
    LProbText.setText(str(int(LProb*100)) + '%')
    RAmtText.setColor(TextColor, colorSpace='rgb')
    RAmtText.setText(RAmt)
    RProbText.setColor(TextColor, colorSpace='rgb')
    RProbText.setText(str(int(RProb*100)) + '%')
    Response.keys = []
    Response.rt = []
    _Response_allKeys = []
    # keep track of which components have finished
    ChoiceComponents = [LAmtText, LProbText, RAmtText, RProbText, Response, Divider]
    for thisComponent in ChoiceComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "Choice" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *LAmtText* updates
        
        # if LAmtText is starting this frame...
        if LAmtText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LAmtText.frameNStart = frameN  # exact frame index
            LAmtText.tStart = t  # local t and not account for scr refresh
            LAmtText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LAmtText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LAmtText.started')
            # update status
            LAmtText.status = STARTED
            LAmtText.setAutoDraw(True)
        
        # if LAmtText is active this frame...
        if LAmtText.status == STARTED:
            # update params
            pass
        
        # if LAmtText is stopping this frame...
        if LAmtText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LAmtText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                LAmtText.tStop = t  # not accounting for scr refresh
                LAmtText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LAmtText.stopped')
                # update status
                LAmtText.status = FINISHED
                LAmtText.setAutoDraw(False)
        
        # *LProbText* updates
        
        # if LProbText is starting this frame...
        if LProbText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LProbText.frameNStart = frameN  # exact frame index
            LProbText.tStart = t  # local t and not account for scr refresh
            LProbText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LProbText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LProbText.started')
            # update status
            LProbText.status = STARTED
            LProbText.setAutoDraw(True)
        
        # if LProbText is active this frame...
        if LProbText.status == STARTED:
            # update params
            pass
        
        # if LProbText is stopping this frame...
        if LProbText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LProbText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                LProbText.tStop = t  # not accounting for scr refresh
                LProbText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LProbText.stopped')
                # update status
                LProbText.status = FINISHED
                LProbText.setAutoDraw(False)
        
        # *RAmtText* updates
        
        # if RAmtText is starting this frame...
        if RAmtText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RAmtText.frameNStart = frameN  # exact frame index
            RAmtText.tStart = t  # local t and not account for scr refresh
            RAmtText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RAmtText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RAmtText.started')
            # update status
            RAmtText.status = STARTED
            RAmtText.setAutoDraw(True)
        
        # if RAmtText is active this frame...
        if RAmtText.status == STARTED:
            # update params
            pass
        
        # if RAmtText is stopping this frame...
        if RAmtText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RAmtText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                RAmtText.tStop = t  # not accounting for scr refresh
                RAmtText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RAmtText.stopped')
                # update status
                RAmtText.status = FINISHED
                RAmtText.setAutoDraw(False)
        
        # *RProbText* updates
        
        # if RProbText is starting this frame...
        if RProbText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RProbText.frameNStart = frameN  # exact frame index
            RProbText.tStart = t  # local t and not account for scr refresh
            RProbText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RProbText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RProbText.started')
            # update status
            RProbText.status = STARTED
            RProbText.setAutoDraw(True)
        
        # if RProbText is active this frame...
        if RProbText.status == STARTED:
            # update params
            pass
        
        # if RProbText is stopping this frame...
        if RProbText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RProbText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                RProbText.tStop = t  # not accounting for scr refresh
                RProbText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RProbText.stopped')
                # update status
                RProbText.status = FINISHED
                RProbText.setAutoDraw(False)
        
        # *Response* updates
        waitOnFlip = False
        
        # if Response is starting this frame...
        if Response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Response.frameNStart = frameN  # exact frame index
            Response.tStart = t  # local t and not account for scr refresh
            Response.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Response, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Response.started')
            # update status
            Response.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(Response.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(Response.clearEvents, eventType='keyboard')  # clear events on next screen flip
        
        # if Response is stopping this frame...
        if Response.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Response.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                Response.tStop = t  # not accounting for scr refresh
                Response.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Response.stopped')
                # update status
                Response.status = FINISHED
                Response.status = FINISHED
        if Response.status == STARTED and not waitOnFlip:
            theseKeys = Response.getKeys(keyList=['left','right'], waitRelease=False)
            _Response_allKeys.extend(theseKeys)
            if len(_Response_allKeys):
                Response.keys = _Response_allKeys[0].name  # just the first key pressed
                Response.rt = _Response_allKeys[0].rt
                Response.duration = _Response_allKeys[0].duration
                # a response ends the routine
                continueRoutine = False
        
        # *Divider* updates
        
        # if Divider is starting this frame...
        if Divider.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Divider.frameNStart = frameN  # exact frame index
            Divider.tStart = t  # local t and not account for scr refresh
            Divider.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Divider, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Divider.started')
            # update status
            Divider.status = STARTED
            Divider.setAutoDraw(True)
        
        # if Divider is active this frame...
        if Divider.status == STARTED:
            # update params
            pass
        
        # if Divider is stopping this frame...
        if Divider.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Divider.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                Divider.tStop = t  # not accounting for scr refresh
                Divider.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Divider.stopped')
                # update status
                Divider.status = FINISHED
                Divider.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ChoiceComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Choice" ---
    for thisComponent in ChoiceComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # Run 'End Routine' code from ChoiceCode
    # Tell the eyetracker what trial this is.
    
    eyetracker.sendMessage("TRIALEND "+str(TrialNumber))
    TrialNumber = TrialNumber + 1
    
    # Proceed to Feedback, or skip to Faster?
    
    if not Response.keys:
        goToFeedback = 0
        sayFaster = 1
    else:
        goToFeedback = 1
        sayFaster = 0
    # check responses
    if Response.keys in ['', [], None]:  # No response was made
        Response.keys = None
    Practice.addData('Response.keys',Response.keys)
    if Response.keys != None:  # we had a response
        Practice.addData('Response.rt', Response.rt)
        Practice.addData('Response.duration', Response.duration)
    # the Routine "Choice" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # --- Prepare to start Routine "Feedback" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from FeedbackCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Show feedback?
    if goToFeedback == 1:
        continueRoutine = True
        FeedbackDuration = 1
    else:
        continueRoutine = False
        FeedbackDuration = 0.01
    
    # Position feedback rectangle based on response in last routine
    rectangle_position = (0,0)
    if Response.keys == 'left':
        rectangle_position = (-.5, 0)
    elif Response.keys == 'right':
        rectangle_position = (.5, 0)
    LAmtText_2.setColor(TextColor, colorSpace='rgb')
    LAmtText_2.setText(LAmt)
    LProbText_2.setColor(TextColor, colorSpace='rgb')
    LProbText_2.setText(str(int(LProb*100)) + '%')
    RAmtText_2.setColor(TextColor, colorSpace='rgb')
    RAmtText_2.setText(RAmt)
    RProbText_2.setColor(TextColor, colorSpace='rgb')
    RProbText_2.setText(str(int(RProb*100)) + '%')
    FeedbackRectangle.setPos(rectangle_position)
    # keep track of which components have finished
    FeedbackComponents = [LAmtText_2, LProbText_2, RAmtText_2, RProbText_2, FeedbackRectangle, Divider_2]
    for thisComponent in FeedbackComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "Feedback" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *LAmtText_2* updates
        
        # if LAmtText_2 is starting this frame...
        if LAmtText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LAmtText_2.frameNStart = frameN  # exact frame index
            LAmtText_2.tStart = t  # local t and not account for scr refresh
            LAmtText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LAmtText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LAmtText_2.started')
            # update status
            LAmtText_2.status = STARTED
            LAmtText_2.setAutoDraw(True)
        
        # if LAmtText_2 is active this frame...
        if LAmtText_2.status == STARTED:
            # update params
            pass
        
        # if LAmtText_2 is stopping this frame...
        if LAmtText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LAmtText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                LAmtText_2.tStop = t  # not accounting for scr refresh
                LAmtText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LAmtText_2.stopped')
                # update status
                LAmtText_2.status = FINISHED
                LAmtText_2.setAutoDraw(False)
        
        # *LProbText_2* updates
        
        # if LProbText_2 is starting this frame...
        if LProbText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LProbText_2.frameNStart = frameN  # exact frame index
            LProbText_2.tStart = t  # local t and not account for scr refresh
            LProbText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LProbText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LProbText_2.started')
            # update status
            LProbText_2.status = STARTED
            LProbText_2.setAutoDraw(True)
        
        # if LProbText_2 is active this frame...
        if LProbText_2.status == STARTED:
            # update params
            pass
        
        # if LProbText_2 is stopping this frame...
        if LProbText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LProbText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                LProbText_2.tStop = t  # not accounting for scr refresh
                LProbText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LProbText_2.stopped')
                # update status
                LProbText_2.status = FINISHED
                LProbText_2.setAutoDraw(False)
        
        # *RAmtText_2* updates
        
        # if RAmtText_2 is starting this frame...
        if RAmtText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RAmtText_2.frameNStart = frameN  # exact frame index
            RAmtText_2.tStart = t  # local t and not account for scr refresh
            RAmtText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RAmtText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RAmtText_2.started')
            # update status
            RAmtText_2.status = STARTED
            RAmtText_2.setAutoDraw(True)
        
        # if RAmtText_2 is active this frame...
        if RAmtText_2.status == STARTED:
            # update params
            pass
        
        # if RAmtText_2 is stopping this frame...
        if RAmtText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RAmtText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                RAmtText_2.tStop = t  # not accounting for scr refresh
                RAmtText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RAmtText_2.stopped')
                # update status
                RAmtText_2.status = FINISHED
                RAmtText_2.setAutoDraw(False)
        
        # *RProbText_2* updates
        
        # if RProbText_2 is starting this frame...
        if RProbText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RProbText_2.frameNStart = frameN  # exact frame index
            RProbText_2.tStart = t  # local t and not account for scr refresh
            RProbText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RProbText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RProbText_2.started')
            # update status
            RProbText_2.status = STARTED
            RProbText_2.setAutoDraw(True)
        
        # if RProbText_2 is active this frame...
        if RProbText_2.status == STARTED:
            # update params
            pass
        
        # if RProbText_2 is stopping this frame...
        if RProbText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RProbText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                RProbText_2.tStop = t  # not accounting for scr refresh
                RProbText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RProbText_2.stopped')
                # update status
                RProbText_2.status = FINISHED
                RProbText_2.setAutoDraw(False)
        
        # *FeedbackRectangle* updates
        
        # if FeedbackRectangle is starting this frame...
        if FeedbackRectangle.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            FeedbackRectangle.frameNStart = frameN  # exact frame index
            FeedbackRectangle.tStart = t  # local t and not account for scr refresh
            FeedbackRectangle.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(FeedbackRectangle, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'FeedbackRectangle.started')
            # update status
            FeedbackRectangle.status = STARTED
            FeedbackRectangle.setAutoDraw(True)
        
        # if FeedbackRectangle is active this frame...
        if FeedbackRectangle.status == STARTED:
            # update params
            pass
        
        # if FeedbackRectangle is stopping this frame...
        if FeedbackRectangle.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > FeedbackRectangle.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                FeedbackRectangle.tStop = t  # not accounting for scr refresh
                FeedbackRectangle.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'FeedbackRectangle.stopped')
                # update status
                FeedbackRectangle.status = FINISHED
                FeedbackRectangle.setAutoDraw(False)
        
        # *Divider_2* updates
        
        # if Divider_2 is starting this frame...
        if Divider_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Divider_2.frameNStart = frameN  # exact frame index
            Divider_2.tStart = t  # local t and not account for scr refresh
            Divider_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Divider_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Divider_2.started')
            # update status
            Divider_2.status = STARTED
            Divider_2.setAutoDraw(True)
        
        # if Divider_2 is active this frame...
        if Divider_2.status == STARTED:
            # update params
            pass
        
        # if Divider_2 is stopping this frame...
        if Divider_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Divider_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                Divider_2.tStop = t  # not accounting for scr refresh
                Divider_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Divider_2.stopped')
                # update status
                Divider_2.status = FINISHED
                Divider_2.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in FeedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Feedback" ---
    for thisComponent in FeedbackComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # the Routine "Feedback" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # --- Prepare to start Routine "ITI" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from ITICode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Turn off eyetracking
    eyetracker.setRecordingState(False)
    
    # Show faster screen?
    if sayFaster == 1:
        ITITextVar = "Faster!"
    else:
        ITITextVar = "   "
    ITIText.setText(ITITextVar)
    # keep track of which components have finished
    ITIComponents = [ITIText]
    for thisComponent in ITIComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "ITI" ---
    routineForceEnded = not continueRoutine
    while continueRoutine and routineTimer.getTime() < 1.0:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *ITIText* updates
        
        # if ITIText is starting this frame...
        if ITIText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            ITIText.frameNStart = frameN  # exact frame index
            ITIText.tStart = t  # local t and not account for scr refresh
            ITIText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(ITIText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'ITIText.started')
            # update status
            ITIText.status = STARTED
            ITIText.setAutoDraw(True)
        
        # if ITIText is active this frame...
        if ITIText.status == STARTED:
            # update params
            pass
        
        # if ITIText is stopping this frame...
        if ITIText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > ITIText.tStartRefresh + 1.0-frameTolerance:
                # keep track of stop time/frame for later
                ITIText.tStop = t  # not accounting for scr refresh
                ITIText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'ITIText.stopped')
                # update status
                ITIText.status = FINISHED
                ITIText.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ITIComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "ITI" ---
    for thisComponent in ITIComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-1.000000)
    thisExp.nextEntry()
    
# completed 1.0 repeats of 'Practice'


# --- Prepare to start Routine "ExperimentBegin" ---
continueRoutine = True
# update component parameters for each repeat
# Run 'Begin Routine' code from ExperimentBeginCode
# Indicator for Practice Trials

Practice = 0;
ExperimentBeginResp.keys = []
ExperimentBeginResp.rt = []
_ExperimentBeginResp_allKeys = []
# keep track of which components have finished
ExperimentBeginComponents = [ExperimentBeginText, ExperimentBeginResp]
for thisComponent in ExperimentBeginComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "ExperimentBegin" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *ExperimentBeginText* updates
    
    # if ExperimentBeginText is starting this frame...
    if ExperimentBeginText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        ExperimentBeginText.frameNStart = frameN  # exact frame index
        ExperimentBeginText.tStart = t  # local t and not account for scr refresh
        ExperimentBeginText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(ExperimentBeginText, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'ExperimentBeginText.started')
        # update status
        ExperimentBeginText.status = STARTED
        ExperimentBeginText.setAutoDraw(True)
    
    # if ExperimentBeginText is active this frame...
    if ExperimentBeginText.status == STARTED:
        # update params
        pass
    
    # *ExperimentBeginResp* updates
    waitOnFlip = False
    
    # if ExperimentBeginResp is starting this frame...
    if ExperimentBeginResp.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        ExperimentBeginResp.frameNStart = frameN  # exact frame index
        ExperimentBeginResp.tStart = t  # local t and not account for scr refresh
        ExperimentBeginResp.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(ExperimentBeginResp, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'ExperimentBeginResp.started')
        # update status
        ExperimentBeginResp.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(ExperimentBeginResp.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(ExperimentBeginResp.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if ExperimentBeginResp.status == STARTED and not waitOnFlip:
        theseKeys = ExperimentBeginResp.getKeys(keyList=['down'], waitRelease=False)
        _ExperimentBeginResp_allKeys.extend(theseKeys)
        if len(_ExperimentBeginResp_allKeys):
            ExperimentBeginResp.keys = _ExperimentBeginResp_allKeys[-1].name  # just the last key pressed
            ExperimentBeginResp.rt = _ExperimentBeginResp_allKeys[-1].rt
            ExperimentBeginResp.duration = _ExperimentBeginResp_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in ExperimentBeginComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "ExperimentBegin" ---
for thisComponent in ExperimentBeginComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if ExperimentBeginResp.keys in ['', [], None]:  # No response was made
    ExperimentBeginResp.keys = None
thisExp.addData('ExperimentBeginResp.keys',ExperimentBeginResp.keys)
if ExperimentBeginResp.keys != None:  # we had a response
    thisExp.addData('ExperimentBeginResp.rt', ExperimentBeginResp.rt)
    thisExp.addData('ExperimentBeginResp.duration', ExperimentBeginResp.duration)
thisExp.nextEntry()
# the Routine "ExperimentBegin" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# --- Prepare to start Routine "StartBlock1" ---
continueRoutine = True
# update component parameters for each repeat
key_resp.keys = []
key_resp.rt = []
_key_resp_allKeys = []
# keep track of which components have finished
StartBlock1Components = [StartBlockText, key_resp]
for thisComponent in StartBlock1Components:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "StartBlock1" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *StartBlockText* updates
    
    # if StartBlockText is starting this frame...
    if StartBlockText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        StartBlockText.frameNStart = frameN  # exact frame index
        StartBlockText.tStart = t  # local t and not account for scr refresh
        StartBlockText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(StartBlockText, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'StartBlockText.started')
        # update status
        StartBlockText.status = STARTED
        StartBlockText.setAutoDraw(True)
    
    # if StartBlockText is active this frame...
    if StartBlockText.status == STARTED:
        # update params
        pass
    
    # *key_resp* updates
    waitOnFlip = False
    
    # if key_resp is starting this frame...
    if key_resp.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        key_resp.frameNStart = frameN  # exact frame index
        key_resp.tStart = t  # local t and not account for scr refresh
        key_resp.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(key_resp, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'key_resp.started')
        # update status
        key_resp.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(key_resp.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(key_resp.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if key_resp.status == STARTED and not waitOnFlip:
        theseKeys = key_resp.getKeys(keyList=['down'], waitRelease=False)
        _key_resp_allKeys.extend(theseKeys)
        if len(_key_resp_allKeys):
            key_resp.keys = _key_resp_allKeys[-1].name  # just the last key pressed
            key_resp.rt = _key_resp_allKeys[-1].rt
            key_resp.duration = _key_resp_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in StartBlock1Components:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "StartBlock1" ---
for thisComponent in StartBlock1Components:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if key_resp.keys in ['', [], None]:  # No response was made
    key_resp.keys = None
thisExp.addData('key_resp.keys',key_resp.keys)
if key_resp.keys != None:  # we had a response
    thisExp.addData('key_resp.rt', key_resp.rt)
    thisExp.addData('key_resp.duration', key_resp.duration)
thisExp.nextEntry()
# the Routine "StartBlock1" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
Trial_Block1 = data.TrialHandler(nReps=1.0, method='random', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('spreadsheet_' + Condition + '1.csv'),
    seed=None, name='Trial_Block1')
thisExp.addLoop(Trial_Block1)  # add the loop to the experiment
thisTrial_Block1 = Trial_Block1.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisTrial_Block1.rgb)
if thisTrial_Block1 != None:
    for paramName in thisTrial_Block1:
        exec('{} = thisTrial_Block1[paramName]'.format(paramName))

for thisTrial_Block1 in Trial_Block1:
    currentLoop = Trial_Block1
    # abbreviate parameter names if possible (e.g. rgb = thisTrial_Block1.rgb)
    if thisTrial_Block1 != None:
        for paramName in thisTrial_Block1:
            exec('{} = thisTrial_Block1[paramName]'.format(paramName))
    
    # --- Prepare to start Routine "FixationCross" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from FixationCrossCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Turn on eyetracking
    eyetracker.setRecordingState(True)
    FixationCrossPolygon.setPos(FixCrossLoc)
    # keep track of which components have finished
    FixationCrossComponents = [FixationCrossPolygon]
    for thisComponent in FixationCrossComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "FixationCross" ---
    routineForceEnded = not continueRoutine
    while continueRoutine and routineTimer.getTime() < 0.5:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *FixationCrossPolygon* updates
        
        # if FixationCrossPolygon is starting this frame...
        if FixationCrossPolygon.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            FixationCrossPolygon.frameNStart = frameN  # exact frame index
            FixationCrossPolygon.tStart = t  # local t and not account for scr refresh
            FixationCrossPolygon.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(FixationCrossPolygon, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'FixationCrossPolygon.started')
            # update status
            FixationCrossPolygon.status = STARTED
            FixationCrossPolygon.setAutoDraw(True)
        
        # if FixationCrossPolygon is active this frame...
        if FixationCrossPolygon.status == STARTED:
            # update params
            pass
        
        # if FixationCrossPolygon is stopping this frame...
        if FixationCrossPolygon.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > FixationCrossPolygon.tStartRefresh + .5-frameTolerance:
                # keep track of stop time/frame for later
                FixationCrossPolygon.tStop = t  # not accounting for scr refresh
                FixationCrossPolygon.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'FixationCrossPolygon.stopped')
                # update status
                FixationCrossPolygon.status = FINISHED
                FixationCrossPolygon.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in FixationCrossComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "FixationCross" ---
    for thisComponent in FixationCrossComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-0.500000)
    
    # --- Prepare to start Routine "Choice" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from ChoiceCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Tell the eyetracker what trial this is.
    
    eyetracker.sendMessage("TRIALSTART "+str(TrialNumber))
    LAmtText.setColor(TextColor, colorSpace='rgb')
    LAmtText.setText(LAmt)
    LProbText.setColor(TextColor, colorSpace='rgb')
    LProbText.setText(str(int(LProb*100)) + '%')
    RAmtText.setColor(TextColor, colorSpace='rgb')
    RAmtText.setText(RAmt)
    RProbText.setColor(TextColor, colorSpace='rgb')
    RProbText.setText(str(int(RProb*100)) + '%')
    Response.keys = []
    Response.rt = []
    _Response_allKeys = []
    # keep track of which components have finished
    ChoiceComponents = [LAmtText, LProbText, RAmtText, RProbText, Response, Divider]
    for thisComponent in ChoiceComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "Choice" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *LAmtText* updates
        
        # if LAmtText is starting this frame...
        if LAmtText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LAmtText.frameNStart = frameN  # exact frame index
            LAmtText.tStart = t  # local t and not account for scr refresh
            LAmtText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LAmtText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LAmtText.started')
            # update status
            LAmtText.status = STARTED
            LAmtText.setAutoDraw(True)
        
        # if LAmtText is active this frame...
        if LAmtText.status == STARTED:
            # update params
            pass
        
        # if LAmtText is stopping this frame...
        if LAmtText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LAmtText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                LAmtText.tStop = t  # not accounting for scr refresh
                LAmtText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LAmtText.stopped')
                # update status
                LAmtText.status = FINISHED
                LAmtText.setAutoDraw(False)
        
        # *LProbText* updates
        
        # if LProbText is starting this frame...
        if LProbText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LProbText.frameNStart = frameN  # exact frame index
            LProbText.tStart = t  # local t and not account for scr refresh
            LProbText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LProbText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LProbText.started')
            # update status
            LProbText.status = STARTED
            LProbText.setAutoDraw(True)
        
        # if LProbText is active this frame...
        if LProbText.status == STARTED:
            # update params
            pass
        
        # if LProbText is stopping this frame...
        if LProbText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LProbText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                LProbText.tStop = t  # not accounting for scr refresh
                LProbText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LProbText.stopped')
                # update status
                LProbText.status = FINISHED
                LProbText.setAutoDraw(False)
        
        # *RAmtText* updates
        
        # if RAmtText is starting this frame...
        if RAmtText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RAmtText.frameNStart = frameN  # exact frame index
            RAmtText.tStart = t  # local t and not account for scr refresh
            RAmtText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RAmtText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RAmtText.started')
            # update status
            RAmtText.status = STARTED
            RAmtText.setAutoDraw(True)
        
        # if RAmtText is active this frame...
        if RAmtText.status == STARTED:
            # update params
            pass
        
        # if RAmtText is stopping this frame...
        if RAmtText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RAmtText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                RAmtText.tStop = t  # not accounting for scr refresh
                RAmtText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RAmtText.stopped')
                # update status
                RAmtText.status = FINISHED
                RAmtText.setAutoDraw(False)
        
        # *RProbText* updates
        
        # if RProbText is starting this frame...
        if RProbText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RProbText.frameNStart = frameN  # exact frame index
            RProbText.tStart = t  # local t and not account for scr refresh
            RProbText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RProbText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RProbText.started')
            # update status
            RProbText.status = STARTED
            RProbText.setAutoDraw(True)
        
        # if RProbText is active this frame...
        if RProbText.status == STARTED:
            # update params
            pass
        
        # if RProbText is stopping this frame...
        if RProbText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RProbText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                RProbText.tStop = t  # not accounting for scr refresh
                RProbText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RProbText.stopped')
                # update status
                RProbText.status = FINISHED
                RProbText.setAutoDraw(False)
        
        # *Response* updates
        waitOnFlip = False
        
        # if Response is starting this frame...
        if Response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Response.frameNStart = frameN  # exact frame index
            Response.tStart = t  # local t and not account for scr refresh
            Response.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Response, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Response.started')
            # update status
            Response.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(Response.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(Response.clearEvents, eventType='keyboard')  # clear events on next screen flip
        
        # if Response is stopping this frame...
        if Response.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Response.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                Response.tStop = t  # not accounting for scr refresh
                Response.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Response.stopped')
                # update status
                Response.status = FINISHED
                Response.status = FINISHED
        if Response.status == STARTED and not waitOnFlip:
            theseKeys = Response.getKeys(keyList=['left','right'], waitRelease=False)
            _Response_allKeys.extend(theseKeys)
            if len(_Response_allKeys):
                Response.keys = _Response_allKeys[0].name  # just the first key pressed
                Response.rt = _Response_allKeys[0].rt
                Response.duration = _Response_allKeys[0].duration
                # a response ends the routine
                continueRoutine = False
        
        # *Divider* updates
        
        # if Divider is starting this frame...
        if Divider.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Divider.frameNStart = frameN  # exact frame index
            Divider.tStart = t  # local t and not account for scr refresh
            Divider.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Divider, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Divider.started')
            # update status
            Divider.status = STARTED
            Divider.setAutoDraw(True)
        
        # if Divider is active this frame...
        if Divider.status == STARTED:
            # update params
            pass
        
        # if Divider is stopping this frame...
        if Divider.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Divider.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                Divider.tStop = t  # not accounting for scr refresh
                Divider.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Divider.stopped')
                # update status
                Divider.status = FINISHED
                Divider.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ChoiceComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Choice" ---
    for thisComponent in ChoiceComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # Run 'End Routine' code from ChoiceCode
    # Tell the eyetracker what trial this is.
    
    eyetracker.sendMessage("TRIALEND "+str(TrialNumber))
    TrialNumber = TrialNumber + 1
    
    # Proceed to Feedback, or skip to Faster?
    
    if not Response.keys:
        goToFeedback = 0
        sayFaster = 1
    else:
        goToFeedback = 1
        sayFaster = 0
    # check responses
    if Response.keys in ['', [], None]:  # No response was made
        Response.keys = None
    Trial_Block1.addData('Response.keys',Response.keys)
    if Response.keys != None:  # we had a response
        Trial_Block1.addData('Response.rt', Response.rt)
        Trial_Block1.addData('Response.duration', Response.duration)
    # the Routine "Choice" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # --- Prepare to start Routine "Feedback" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from FeedbackCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Show feedback?
    if goToFeedback == 1:
        continueRoutine = True
        FeedbackDuration = 1
    else:
        continueRoutine = False
        FeedbackDuration = 0.01
    
    # Position feedback rectangle based on response in last routine
    rectangle_position = (0,0)
    if Response.keys == 'left':
        rectangle_position = (-.5, 0)
    elif Response.keys == 'right':
        rectangle_position = (.5, 0)
    LAmtText_2.setColor(TextColor, colorSpace='rgb')
    LAmtText_2.setText(LAmt)
    LProbText_2.setColor(TextColor, colorSpace='rgb')
    LProbText_2.setText(str(int(LProb*100)) + '%')
    RAmtText_2.setColor(TextColor, colorSpace='rgb')
    RAmtText_2.setText(RAmt)
    RProbText_2.setColor(TextColor, colorSpace='rgb')
    RProbText_2.setText(str(int(RProb*100)) + '%')
    FeedbackRectangle.setPos(rectangle_position)
    # keep track of which components have finished
    FeedbackComponents = [LAmtText_2, LProbText_2, RAmtText_2, RProbText_2, FeedbackRectangle, Divider_2]
    for thisComponent in FeedbackComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "Feedback" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *LAmtText_2* updates
        
        # if LAmtText_2 is starting this frame...
        if LAmtText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LAmtText_2.frameNStart = frameN  # exact frame index
            LAmtText_2.tStart = t  # local t and not account for scr refresh
            LAmtText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LAmtText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LAmtText_2.started')
            # update status
            LAmtText_2.status = STARTED
            LAmtText_2.setAutoDraw(True)
        
        # if LAmtText_2 is active this frame...
        if LAmtText_2.status == STARTED:
            # update params
            pass
        
        # if LAmtText_2 is stopping this frame...
        if LAmtText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LAmtText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                LAmtText_2.tStop = t  # not accounting for scr refresh
                LAmtText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LAmtText_2.stopped')
                # update status
                LAmtText_2.status = FINISHED
                LAmtText_2.setAutoDraw(False)
        
        # *LProbText_2* updates
        
        # if LProbText_2 is starting this frame...
        if LProbText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LProbText_2.frameNStart = frameN  # exact frame index
            LProbText_2.tStart = t  # local t and not account for scr refresh
            LProbText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LProbText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LProbText_2.started')
            # update status
            LProbText_2.status = STARTED
            LProbText_2.setAutoDraw(True)
        
        # if LProbText_2 is active this frame...
        if LProbText_2.status == STARTED:
            # update params
            pass
        
        # if LProbText_2 is stopping this frame...
        if LProbText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LProbText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                LProbText_2.tStop = t  # not accounting for scr refresh
                LProbText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LProbText_2.stopped')
                # update status
                LProbText_2.status = FINISHED
                LProbText_2.setAutoDraw(False)
        
        # *RAmtText_2* updates
        
        # if RAmtText_2 is starting this frame...
        if RAmtText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RAmtText_2.frameNStart = frameN  # exact frame index
            RAmtText_2.tStart = t  # local t and not account for scr refresh
            RAmtText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RAmtText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RAmtText_2.started')
            # update status
            RAmtText_2.status = STARTED
            RAmtText_2.setAutoDraw(True)
        
        # if RAmtText_2 is active this frame...
        if RAmtText_2.status == STARTED:
            # update params
            pass
        
        # if RAmtText_2 is stopping this frame...
        if RAmtText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RAmtText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                RAmtText_2.tStop = t  # not accounting for scr refresh
                RAmtText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RAmtText_2.stopped')
                # update status
                RAmtText_2.status = FINISHED
                RAmtText_2.setAutoDraw(False)
        
        # *RProbText_2* updates
        
        # if RProbText_2 is starting this frame...
        if RProbText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RProbText_2.frameNStart = frameN  # exact frame index
            RProbText_2.tStart = t  # local t and not account for scr refresh
            RProbText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RProbText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RProbText_2.started')
            # update status
            RProbText_2.status = STARTED
            RProbText_2.setAutoDraw(True)
        
        # if RProbText_2 is active this frame...
        if RProbText_2.status == STARTED:
            # update params
            pass
        
        # if RProbText_2 is stopping this frame...
        if RProbText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RProbText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                RProbText_2.tStop = t  # not accounting for scr refresh
                RProbText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RProbText_2.stopped')
                # update status
                RProbText_2.status = FINISHED
                RProbText_2.setAutoDraw(False)
        
        # *FeedbackRectangle* updates
        
        # if FeedbackRectangle is starting this frame...
        if FeedbackRectangle.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            FeedbackRectangle.frameNStart = frameN  # exact frame index
            FeedbackRectangle.tStart = t  # local t and not account for scr refresh
            FeedbackRectangle.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(FeedbackRectangle, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'FeedbackRectangle.started')
            # update status
            FeedbackRectangle.status = STARTED
            FeedbackRectangle.setAutoDraw(True)
        
        # if FeedbackRectangle is active this frame...
        if FeedbackRectangle.status == STARTED:
            # update params
            pass
        
        # if FeedbackRectangle is stopping this frame...
        if FeedbackRectangle.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > FeedbackRectangle.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                FeedbackRectangle.tStop = t  # not accounting for scr refresh
                FeedbackRectangle.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'FeedbackRectangle.stopped')
                # update status
                FeedbackRectangle.status = FINISHED
                FeedbackRectangle.setAutoDraw(False)
        
        # *Divider_2* updates
        
        # if Divider_2 is starting this frame...
        if Divider_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Divider_2.frameNStart = frameN  # exact frame index
            Divider_2.tStart = t  # local t and not account for scr refresh
            Divider_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Divider_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Divider_2.started')
            # update status
            Divider_2.status = STARTED
            Divider_2.setAutoDraw(True)
        
        # if Divider_2 is active this frame...
        if Divider_2.status == STARTED:
            # update params
            pass
        
        # if Divider_2 is stopping this frame...
        if Divider_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Divider_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                Divider_2.tStop = t  # not accounting for scr refresh
                Divider_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Divider_2.stopped')
                # update status
                Divider_2.status = FINISHED
                Divider_2.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in FeedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Feedback" ---
    for thisComponent in FeedbackComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # the Routine "Feedback" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # --- Prepare to start Routine "ITI" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from ITICode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Turn off eyetracking
    eyetracker.setRecordingState(False)
    
    # Show faster screen?
    if sayFaster == 1:
        ITITextVar = "Faster!"
    else:
        ITITextVar = "   "
    ITIText.setText(ITITextVar)
    # keep track of which components have finished
    ITIComponents = [ITIText]
    for thisComponent in ITIComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "ITI" ---
    routineForceEnded = not continueRoutine
    while continueRoutine and routineTimer.getTime() < 1.0:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *ITIText* updates
        
        # if ITIText is starting this frame...
        if ITIText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            ITIText.frameNStart = frameN  # exact frame index
            ITIText.tStart = t  # local t and not account for scr refresh
            ITIText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(ITIText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'ITIText.started')
            # update status
            ITIText.status = STARTED
            ITIText.setAutoDraw(True)
        
        # if ITIText is active this frame...
        if ITIText.status == STARTED:
            # update params
            pass
        
        # if ITIText is stopping this frame...
        if ITIText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > ITIText.tStartRefresh + 1.0-frameTolerance:
                # keep track of stop time/frame for later
                ITIText.tStop = t  # not accounting for scr refresh
                ITIText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'ITIText.stopped')
                # update status
                ITIText.status = FINISHED
                ITIText.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ITIComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "ITI" ---
    for thisComponent in ITIComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-1.000000)
    thisExp.nextEntry()
    
# completed 1.0 repeats of 'Trial_Block1'


# --- Prepare to start Routine "EndBlock1" ---
continueRoutine = True
# update component parameters for each repeat
EndBlock1Text.setText("End of Block 1 of 2.\n\nFeel free to take a break. When you're ready, please let the experimenter know and press 'Down Arrow' to continue.")
EndBlock1Response.keys = []
EndBlock1Response.rt = []
_EndBlock1Response_allKeys = []
# keep track of which components have finished
EndBlock1Components = [EndBlock1Text, EndBlock1Response]
for thisComponent in EndBlock1Components:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "EndBlock1" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *EndBlock1Text* updates
    
    # if EndBlock1Text is starting this frame...
    if EndBlock1Text.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        EndBlock1Text.frameNStart = frameN  # exact frame index
        EndBlock1Text.tStart = t  # local t and not account for scr refresh
        EndBlock1Text.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(EndBlock1Text, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'EndBlock1Text.started')
        # update status
        EndBlock1Text.status = STARTED
        EndBlock1Text.setAutoDraw(True)
    
    # if EndBlock1Text is active this frame...
    if EndBlock1Text.status == STARTED:
        # update params
        pass
    
    # *EndBlock1Response* updates
    waitOnFlip = False
    
    # if EndBlock1Response is starting this frame...
    if EndBlock1Response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        EndBlock1Response.frameNStart = frameN  # exact frame index
        EndBlock1Response.tStart = t  # local t and not account for scr refresh
        EndBlock1Response.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(EndBlock1Response, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'EndBlock1Response.started')
        # update status
        EndBlock1Response.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(EndBlock1Response.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(EndBlock1Response.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if EndBlock1Response.status == STARTED and not waitOnFlip:
        theseKeys = EndBlock1Response.getKeys(keyList=['down'], waitRelease=False)
        _EndBlock1Response_allKeys.extend(theseKeys)
        if len(_EndBlock1Response_allKeys):
            EndBlock1Response.keys = _EndBlock1Response_allKeys[-1].name  # just the last key pressed
            EndBlock1Response.rt = _EndBlock1Response_allKeys[-1].rt
            EndBlock1Response.duration = _EndBlock1Response_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in EndBlock1Components:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "EndBlock1" ---
for thisComponent in EndBlock1Components:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if EndBlock1Response.keys in ['', [], None]:  # No response was made
    EndBlock1Response.keys = None
thisExp.addData('EndBlock1Response.keys',EndBlock1Response.keys)
if EndBlock1Response.keys != None:  # we had a response
    thisExp.addData('EndBlock1Response.rt', EndBlock1Response.rt)
    thisExp.addData('EndBlock1Response.duration', EndBlock1Response.duration)
thisExp.nextEntry()
# the Routine "EndBlock1" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# --- Prepare to start Routine "StartBlock2" ---
continueRoutine = True
# update component parameters for each repeat
key_resp_2.keys = []
key_resp_2.rt = []
_key_resp_2_allKeys = []
# keep track of which components have finished
StartBlock2Components = [StartBlockText_2, key_resp_2]
for thisComponent in StartBlock2Components:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "StartBlock2" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *StartBlockText_2* updates
    
    # if StartBlockText_2 is starting this frame...
    if StartBlockText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        StartBlockText_2.frameNStart = frameN  # exact frame index
        StartBlockText_2.tStart = t  # local t and not account for scr refresh
        StartBlockText_2.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(StartBlockText_2, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'StartBlockText_2.started')
        # update status
        StartBlockText_2.status = STARTED
        StartBlockText_2.setAutoDraw(True)
    
    # if StartBlockText_2 is active this frame...
    if StartBlockText_2.status == STARTED:
        # update params
        pass
    
    # *key_resp_2* updates
    waitOnFlip = False
    
    # if key_resp_2 is starting this frame...
    if key_resp_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        key_resp_2.frameNStart = frameN  # exact frame index
        key_resp_2.tStart = t  # local t and not account for scr refresh
        key_resp_2.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(key_resp_2, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'key_resp_2.started')
        # update status
        key_resp_2.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(key_resp_2.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(key_resp_2.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if key_resp_2.status == STARTED and not waitOnFlip:
        theseKeys = key_resp_2.getKeys(keyList=['down'], waitRelease=False)
        _key_resp_2_allKeys.extend(theseKeys)
        if len(_key_resp_2_allKeys):
            key_resp_2.keys = _key_resp_2_allKeys[-1].name  # just the last key pressed
            key_resp_2.rt = _key_resp_2_allKeys[-1].rt
            key_resp_2.duration = _key_resp_2_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in StartBlock2Components:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "StartBlock2" ---
for thisComponent in StartBlock2Components:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if key_resp_2.keys in ['', [], None]:  # No response was made
    key_resp_2.keys = None
thisExp.addData('key_resp_2.keys',key_resp_2.keys)
if key_resp_2.keys != None:  # we had a response
    thisExp.addData('key_resp_2.rt', key_resp_2.rt)
    thisExp.addData('key_resp_2.duration', key_resp_2.duration)
thisExp.nextEntry()
# the Routine "StartBlock2" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
Trial_Block2 = data.TrialHandler(nReps=1.0, method='random', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('spreadsheet_' + Condition + '2.csv'),
    seed=None, name='Trial_Block2')
thisExp.addLoop(Trial_Block2)  # add the loop to the experiment
thisTrial_Block2 = Trial_Block2.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisTrial_Block2.rgb)
if thisTrial_Block2 != None:
    for paramName in thisTrial_Block2:
        exec('{} = thisTrial_Block2[paramName]'.format(paramName))

for thisTrial_Block2 in Trial_Block2:
    currentLoop = Trial_Block2
    # abbreviate parameter names if possible (e.g. rgb = thisTrial_Block2.rgb)
    if thisTrial_Block2 != None:
        for paramName in thisTrial_Block2:
            exec('{} = thisTrial_Block2[paramName]'.format(paramName))
    
    # --- Prepare to start Routine "FixationCross" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from FixationCrossCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Turn on eyetracking
    eyetracker.setRecordingState(True)
    FixationCrossPolygon.setPos(FixCrossLoc)
    # keep track of which components have finished
    FixationCrossComponents = [FixationCrossPolygon]
    for thisComponent in FixationCrossComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "FixationCross" ---
    routineForceEnded = not continueRoutine
    while continueRoutine and routineTimer.getTime() < 0.5:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *FixationCrossPolygon* updates
        
        # if FixationCrossPolygon is starting this frame...
        if FixationCrossPolygon.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            FixationCrossPolygon.frameNStart = frameN  # exact frame index
            FixationCrossPolygon.tStart = t  # local t and not account for scr refresh
            FixationCrossPolygon.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(FixationCrossPolygon, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'FixationCrossPolygon.started')
            # update status
            FixationCrossPolygon.status = STARTED
            FixationCrossPolygon.setAutoDraw(True)
        
        # if FixationCrossPolygon is active this frame...
        if FixationCrossPolygon.status == STARTED:
            # update params
            pass
        
        # if FixationCrossPolygon is stopping this frame...
        if FixationCrossPolygon.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > FixationCrossPolygon.tStartRefresh + .5-frameTolerance:
                # keep track of stop time/frame for later
                FixationCrossPolygon.tStop = t  # not accounting for scr refresh
                FixationCrossPolygon.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'FixationCrossPolygon.stopped')
                # update status
                FixationCrossPolygon.status = FINISHED
                FixationCrossPolygon.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in FixationCrossComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "FixationCross" ---
    for thisComponent in FixationCrossComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-0.500000)
    
    # --- Prepare to start Routine "Choice" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from ChoiceCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Tell the eyetracker what trial this is.
    
    eyetracker.sendMessage("TRIALSTART "+str(TrialNumber))
    LAmtText.setColor(TextColor, colorSpace='rgb')
    LAmtText.setText(LAmt)
    LProbText.setColor(TextColor, colorSpace='rgb')
    LProbText.setText(str(int(LProb*100)) + '%')
    RAmtText.setColor(TextColor, colorSpace='rgb')
    RAmtText.setText(RAmt)
    RProbText.setColor(TextColor, colorSpace='rgb')
    RProbText.setText(str(int(RProb*100)) + '%')
    Response.keys = []
    Response.rt = []
    _Response_allKeys = []
    # keep track of which components have finished
    ChoiceComponents = [LAmtText, LProbText, RAmtText, RProbText, Response, Divider]
    for thisComponent in ChoiceComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "Choice" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *LAmtText* updates
        
        # if LAmtText is starting this frame...
        if LAmtText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LAmtText.frameNStart = frameN  # exact frame index
            LAmtText.tStart = t  # local t and not account for scr refresh
            LAmtText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LAmtText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LAmtText.started')
            # update status
            LAmtText.status = STARTED
            LAmtText.setAutoDraw(True)
        
        # if LAmtText is active this frame...
        if LAmtText.status == STARTED:
            # update params
            pass
        
        # if LAmtText is stopping this frame...
        if LAmtText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LAmtText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                LAmtText.tStop = t  # not accounting for scr refresh
                LAmtText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LAmtText.stopped')
                # update status
                LAmtText.status = FINISHED
                LAmtText.setAutoDraw(False)
        
        # *LProbText* updates
        
        # if LProbText is starting this frame...
        if LProbText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LProbText.frameNStart = frameN  # exact frame index
            LProbText.tStart = t  # local t and not account for scr refresh
            LProbText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LProbText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LProbText.started')
            # update status
            LProbText.status = STARTED
            LProbText.setAutoDraw(True)
        
        # if LProbText is active this frame...
        if LProbText.status == STARTED:
            # update params
            pass
        
        # if LProbText is stopping this frame...
        if LProbText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LProbText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                LProbText.tStop = t  # not accounting for scr refresh
                LProbText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LProbText.stopped')
                # update status
                LProbText.status = FINISHED
                LProbText.setAutoDraw(False)
        
        # *RAmtText* updates
        
        # if RAmtText is starting this frame...
        if RAmtText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RAmtText.frameNStart = frameN  # exact frame index
            RAmtText.tStart = t  # local t and not account for scr refresh
            RAmtText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RAmtText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RAmtText.started')
            # update status
            RAmtText.status = STARTED
            RAmtText.setAutoDraw(True)
        
        # if RAmtText is active this frame...
        if RAmtText.status == STARTED:
            # update params
            pass
        
        # if RAmtText is stopping this frame...
        if RAmtText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RAmtText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                RAmtText.tStop = t  # not accounting for scr refresh
                RAmtText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RAmtText.stopped')
                # update status
                RAmtText.status = FINISHED
                RAmtText.setAutoDraw(False)
        
        # *RProbText* updates
        
        # if RProbText is starting this frame...
        if RProbText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RProbText.frameNStart = frameN  # exact frame index
            RProbText.tStart = t  # local t and not account for scr refresh
            RProbText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RProbText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RProbText.started')
            # update status
            RProbText.status = STARTED
            RProbText.setAutoDraw(True)
        
        # if RProbText is active this frame...
        if RProbText.status == STARTED:
            # update params
            pass
        
        # if RProbText is stopping this frame...
        if RProbText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RProbText.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                RProbText.tStop = t  # not accounting for scr refresh
                RProbText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RProbText.stopped')
                # update status
                RProbText.status = FINISHED
                RProbText.setAutoDraw(False)
        
        # *Response* updates
        waitOnFlip = False
        
        # if Response is starting this frame...
        if Response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Response.frameNStart = frameN  # exact frame index
            Response.tStart = t  # local t and not account for scr refresh
            Response.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Response, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Response.started')
            # update status
            Response.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(Response.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(Response.clearEvents, eventType='keyboard')  # clear events on next screen flip
        
        # if Response is stopping this frame...
        if Response.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Response.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                Response.tStop = t  # not accounting for scr refresh
                Response.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Response.stopped')
                # update status
                Response.status = FINISHED
                Response.status = FINISHED
        if Response.status == STARTED and not waitOnFlip:
            theseKeys = Response.getKeys(keyList=['left','right'], waitRelease=False)
            _Response_allKeys.extend(theseKeys)
            if len(_Response_allKeys):
                Response.keys = _Response_allKeys[0].name  # just the first key pressed
                Response.rt = _Response_allKeys[0].rt
                Response.duration = _Response_allKeys[0].duration
                # a response ends the routine
                continueRoutine = False
        
        # *Divider* updates
        
        # if Divider is starting this frame...
        if Divider.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Divider.frameNStart = frameN  # exact frame index
            Divider.tStart = t  # local t and not account for scr refresh
            Divider.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Divider, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Divider.started')
            # update status
            Divider.status = STARTED
            Divider.setAutoDraw(True)
        
        # if Divider is active this frame...
        if Divider.status == STARTED:
            # update params
            pass
        
        # if Divider is stopping this frame...
        if Divider.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Divider.tStartRefresh + MaxDecisionTime-frameTolerance:
                # keep track of stop time/frame for later
                Divider.tStop = t  # not accounting for scr refresh
                Divider.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Divider.stopped')
                # update status
                Divider.status = FINISHED
                Divider.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ChoiceComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Choice" ---
    for thisComponent in ChoiceComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # Run 'End Routine' code from ChoiceCode
    # Tell the eyetracker what trial this is.
    
    eyetracker.sendMessage("TRIALEND "+str(TrialNumber))
    TrialNumber = TrialNumber + 1
    
    # Proceed to Feedback, or skip to Faster?
    
    if not Response.keys:
        goToFeedback = 0
        sayFaster = 1
    else:
        goToFeedback = 1
        sayFaster = 0
    # check responses
    if Response.keys in ['', [], None]:  # No response was made
        Response.keys = None
    Trial_Block2.addData('Response.keys',Response.keys)
    if Response.keys != None:  # we had a response
        Trial_Block2.addData('Response.rt', Response.rt)
        Trial_Block2.addData('Response.duration', Response.duration)
    # the Routine "Choice" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # --- Prepare to start Routine "Feedback" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from FeedbackCode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Show feedback?
    if goToFeedback == 1:
        continueRoutine = True
        FeedbackDuration = 1
    else:
        continueRoutine = False
        FeedbackDuration = 0.01
    
    # Position feedback rectangle based on response in last routine
    rectangle_position = (0,0)
    if Response.keys == 'left':
        rectangle_position = (-.5, 0)
    elif Response.keys == 'right':
        rectangle_position = (.5, 0)
    LAmtText_2.setColor(TextColor, colorSpace='rgb')
    LAmtText_2.setText(LAmt)
    LProbText_2.setColor(TextColor, colorSpace='rgb')
    LProbText_2.setText(str(int(LProb*100)) + '%')
    RAmtText_2.setColor(TextColor, colorSpace='rgb')
    RAmtText_2.setText(RAmt)
    RProbText_2.setColor(TextColor, colorSpace='rgb')
    RProbText_2.setText(str(int(RProb*100)) + '%')
    FeedbackRectangle.setPos(rectangle_position)
    # keep track of which components have finished
    FeedbackComponents = [LAmtText_2, LProbText_2, RAmtText_2, RProbText_2, FeedbackRectangle, Divider_2]
    for thisComponent in FeedbackComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "Feedback" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *LAmtText_2* updates
        
        # if LAmtText_2 is starting this frame...
        if LAmtText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LAmtText_2.frameNStart = frameN  # exact frame index
            LAmtText_2.tStart = t  # local t and not account for scr refresh
            LAmtText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LAmtText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LAmtText_2.started')
            # update status
            LAmtText_2.status = STARTED
            LAmtText_2.setAutoDraw(True)
        
        # if LAmtText_2 is active this frame...
        if LAmtText_2.status == STARTED:
            # update params
            pass
        
        # if LAmtText_2 is stopping this frame...
        if LAmtText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LAmtText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                LAmtText_2.tStop = t  # not accounting for scr refresh
                LAmtText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LAmtText_2.stopped')
                # update status
                LAmtText_2.status = FINISHED
                LAmtText_2.setAutoDraw(False)
        
        # *LProbText_2* updates
        
        # if LProbText_2 is starting this frame...
        if LProbText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            LProbText_2.frameNStart = frameN  # exact frame index
            LProbText_2.tStart = t  # local t and not account for scr refresh
            LProbText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(LProbText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'LProbText_2.started')
            # update status
            LProbText_2.status = STARTED
            LProbText_2.setAutoDraw(True)
        
        # if LProbText_2 is active this frame...
        if LProbText_2.status == STARTED:
            # update params
            pass
        
        # if LProbText_2 is stopping this frame...
        if LProbText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > LProbText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                LProbText_2.tStop = t  # not accounting for scr refresh
                LProbText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'LProbText_2.stopped')
                # update status
                LProbText_2.status = FINISHED
                LProbText_2.setAutoDraw(False)
        
        # *RAmtText_2* updates
        
        # if RAmtText_2 is starting this frame...
        if RAmtText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RAmtText_2.frameNStart = frameN  # exact frame index
            RAmtText_2.tStart = t  # local t and not account for scr refresh
            RAmtText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RAmtText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RAmtText_2.started')
            # update status
            RAmtText_2.status = STARTED
            RAmtText_2.setAutoDraw(True)
        
        # if RAmtText_2 is active this frame...
        if RAmtText_2.status == STARTED:
            # update params
            pass
        
        # if RAmtText_2 is stopping this frame...
        if RAmtText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RAmtText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                RAmtText_2.tStop = t  # not accounting for scr refresh
                RAmtText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RAmtText_2.stopped')
                # update status
                RAmtText_2.status = FINISHED
                RAmtText_2.setAutoDraw(False)
        
        # *RProbText_2* updates
        
        # if RProbText_2 is starting this frame...
        if RProbText_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            RProbText_2.frameNStart = frameN  # exact frame index
            RProbText_2.tStart = t  # local t and not account for scr refresh
            RProbText_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RProbText_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'RProbText_2.started')
            # update status
            RProbText_2.status = STARTED
            RProbText_2.setAutoDraw(True)
        
        # if RProbText_2 is active this frame...
        if RProbText_2.status == STARTED:
            # update params
            pass
        
        # if RProbText_2 is stopping this frame...
        if RProbText_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > RProbText_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                RProbText_2.tStop = t  # not accounting for scr refresh
                RProbText_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'RProbText_2.stopped')
                # update status
                RProbText_2.status = FINISHED
                RProbText_2.setAutoDraw(False)
        
        # *FeedbackRectangle* updates
        
        # if FeedbackRectangle is starting this frame...
        if FeedbackRectangle.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            FeedbackRectangle.frameNStart = frameN  # exact frame index
            FeedbackRectangle.tStart = t  # local t and not account for scr refresh
            FeedbackRectangle.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(FeedbackRectangle, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'FeedbackRectangle.started')
            # update status
            FeedbackRectangle.status = STARTED
            FeedbackRectangle.setAutoDraw(True)
        
        # if FeedbackRectangle is active this frame...
        if FeedbackRectangle.status == STARTED:
            # update params
            pass
        
        # if FeedbackRectangle is stopping this frame...
        if FeedbackRectangle.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > FeedbackRectangle.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                FeedbackRectangle.tStop = t  # not accounting for scr refresh
                FeedbackRectangle.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'FeedbackRectangle.stopped')
                # update status
                FeedbackRectangle.status = FINISHED
                FeedbackRectangle.setAutoDraw(False)
        
        # *Divider_2* updates
        
        # if Divider_2 is starting this frame...
        if Divider_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            Divider_2.frameNStart = frameN  # exact frame index
            Divider_2.tStart = t  # local t and not account for scr refresh
            Divider_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(Divider_2, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'Divider_2.started')
            # update status
            Divider_2.status = STARTED
            Divider_2.setAutoDraw(True)
        
        # if Divider_2 is active this frame...
        if Divider_2.status == STARTED:
            # update params
            pass
        
        # if Divider_2 is stopping this frame...
        if Divider_2.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > Divider_2.tStartRefresh + FeedbackDuration-frameTolerance:
                # keep track of stop time/frame for later
                Divider_2.tStop = t  # not accounting for scr refresh
                Divider_2.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'Divider_2.stopped')
                # update status
                Divider_2.status = FINISHED
                Divider_2.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in FeedbackComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "Feedback" ---
    for thisComponent in FeedbackComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # the Routine "Feedback" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # --- Prepare to start Routine "ITI" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from ITICode
    # Skip if session 2 and practice trial.
    if Block == 2 and Practice == 1:
        continueRoutine = False
    
    # Turn off eyetracking
    eyetracker.setRecordingState(False)
    
    # Show faster screen?
    if sayFaster == 1:
        ITITextVar = "Faster!"
    else:
        ITITextVar = "   "
    ITIText.setText(ITITextVar)
    # keep track of which components have finished
    ITIComponents = [ITIText]
    for thisComponent in ITIComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "ITI" ---
    routineForceEnded = not continueRoutine
    while continueRoutine and routineTimer.getTime() < 1.0:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *ITIText* updates
        
        # if ITIText is starting this frame...
        if ITIText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            ITIText.frameNStart = frameN  # exact frame index
            ITIText.tStart = t  # local t and not account for scr refresh
            ITIText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(ITIText, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'ITIText.started')
            # update status
            ITIText.status = STARTED
            ITIText.setAutoDraw(True)
        
        # if ITIText is active this frame...
        if ITIText.status == STARTED:
            # update params
            pass
        
        # if ITIText is stopping this frame...
        if ITIText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > ITIText.tStartRefresh + 1.0-frameTolerance:
                # keep track of stop time/frame for later
                ITIText.tStop = t  # not accounting for scr refresh
                ITIText.frameNStop = frameN  # exact frame index
                # add timestamp to datafile
                thisExp.timestampOnFlip(win, 'ITIText.stopped')
                # update status
                ITIText.status = FINISHED
                ITIText.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
            if eyetracker:
                eyetracker.setConnectionState(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in ITIComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "ITI" ---
    for thisComponent in ITIComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
    if routineForceEnded:
        routineTimer.reset()
    else:
        routineTimer.addTime(-1.000000)
    thisExp.nextEntry()
    
# completed 1.0 repeats of 'Trial_Block2'


# --- Prepare to start Routine "EndBlock2" ---
continueRoutine = True
# update component parameters for each repeat
EndBlock2Text.setText("End of Block 2 of 2. \n\nPress 'Down Arrow' to select a trial and play the gamble selected in that trial.")
EndBlock2Response.keys = []
EndBlock2Response.rt = []
_EndBlock2Response_allKeys = []
# keep track of which components have finished
EndBlock2Components = [EndBlock2Text, EndBlock2Response]
for thisComponent in EndBlock2Components:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "EndBlock2" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *EndBlock2Text* updates
    
    # if EndBlock2Text is starting this frame...
    if EndBlock2Text.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        EndBlock2Text.frameNStart = frameN  # exact frame index
        EndBlock2Text.tStart = t  # local t and not account for scr refresh
        EndBlock2Text.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(EndBlock2Text, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'EndBlock2Text.started')
        # update status
        EndBlock2Text.status = STARTED
        EndBlock2Text.setAutoDraw(True)
    
    # if EndBlock2Text is active this frame...
    if EndBlock2Text.status == STARTED:
        # update params
        pass
    
    # *EndBlock2Response* updates
    waitOnFlip = False
    
    # if EndBlock2Response is starting this frame...
    if EndBlock2Response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        EndBlock2Response.frameNStart = frameN  # exact frame index
        EndBlock2Response.tStart = t  # local t and not account for scr refresh
        EndBlock2Response.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(EndBlock2Response, 'tStartRefresh')  # time at next scr refresh
        # add timestamp to datafile
        thisExp.timestampOnFlip(win, 'EndBlock2Response.started')
        # update status
        EndBlock2Response.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(EndBlock2Response.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(EndBlock2Response.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if EndBlock2Response.status == STARTED and not waitOnFlip:
        theseKeys = EndBlock2Response.getKeys(keyList=['down'], waitRelease=False)
        _EndBlock2Response_allKeys.extend(theseKeys)
        if len(_EndBlock2Response_allKeys):
            EndBlock2Response.keys = _EndBlock2Response_allKeys[-1].name  # just the last key pressed
            EndBlock2Response.rt = _EndBlock2Response_allKeys[-1].rt
            EndBlock2Response.duration = _EndBlock2Response_allKeys[-1].duration
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in EndBlock2Components:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "EndBlock2" ---
for thisComponent in EndBlock2Components:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# check responses
if EndBlock2Response.keys in ['', [], None]:  # No response was made
    EndBlock2Response.keys = None
thisExp.addData('EndBlock2Response.keys',EndBlock2Response.keys)
if EndBlock2Response.keys != None:  # we had a response
    thisExp.addData('EndBlock2Response.rt', EndBlock2Response.rt)
    thisExp.addData('EndBlock2Response.duration', EndBlock2Response.duration)
thisExp.nextEntry()
# the Routine "EndBlock2" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# --- Prepare to start Routine "EndCode" ---
continueRoutine = True
# update component parameters for each repeat
# keep track of which components have finished
EndCodeComponents = []
for thisComponent in EndCodeComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
frameN = -1

# --- Run Routine "EndCode" ---
routineForceEnded = not continueRoutine
while continueRoutine:
    # get current time
    t = routineTimer.getTime()
    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
        if eyetracker:
            eyetracker.setConnectionState(False)
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        routineForceEnded = True
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in EndCodeComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# --- Ending Routine "EndCode" ---
for thisComponent in EndCodeComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# Run 'End Routine' code from EndCodeCode
# Close the connection with the eyetracker.
# This should result in Eyelink saving the EDF file to your default data folder.

if eyetracker:
    eyetracker.setConnectionState(False)
    

# the Routine "EndCode" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# --- End experiment ---
# Flip one final time so any remaining win.callOnFlip() 
# and win.timeOnFlip() tasks get executed before quitting
win.flip()

# these shouldn't be strictly necessary (should auto-save)
thisExp.saveAsWideText(filename+'.csv', delim='comma')
thisExp.saveAsPickle(filename)
logging.flush()
# make sure everything is closed down
if eyetracker:
    eyetracker.setConnectionState(False)
thisExp.abort()  # or data files will save again on exit
win.close()
core.quit()
