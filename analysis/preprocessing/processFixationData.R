# ##################################################################################################
# This script takes in a dataframe with one trial's worth of eyetracking data. It converts that data
# into something analyzable, then returns that converted data as a dataframe.
# Author: Brenden Eum (2023)
#
# Dependencies:
#
# Input:
# - A dataframe with slighly preprocessed eyetracking data (see asc2csv_fixations.R).
# - What does the input dataframe look like? As long as these variables exist, you're good to go!
#
# trial = trial number
# event = the eyetracker event (msg:message, sfix:start fix, efix:end fix, *sacc: saccade)
# timestart = when did the event start
# timeend = when did the event end
# duration = duration of event
# xPos = x coordinate of fixation event
# yPos = y coordinate of fixation event
# pupil = some measure of pupil dilation, either area or diameter
#
#
# Output:
# - A dataframe with preprocessed eyetracking data that is ready for analysis.
#
# trial_number  =   See description above.
# fix_loc       =   Location of fixation (1=L, 2=R, 4=Neither L or R)
# fix_num       =   Which fixation in the trial (first, second, third, ...)?
# fix_start     =   The start time (ms) of this fixation, with respect to stimulus onset.
# fix_end       =   The end time (ms) of this fixation, with respect to stimulus onset.
# fix_dur       =   The duration of the fixation (ms).
#
# Notes:
#
# ##################################################################################################

processFixationData <- function(df) {

  return(yo)
}