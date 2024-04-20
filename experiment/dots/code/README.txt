README file for Win/Loss Lottery experiment

Instructions: 
1.	To run the experiment, open the “main_task.m” file and click the “Run” button in Matlab’s editor tab. 

2.	Enter the subject ID (SID), for the participant. The SID must not exceed a 4-digit number, otherwise Eye-Link will not be able to save the data and the task will fail. 


3.	Enter the Block Type. 

	a.	For the Win Block enter “win” into the console

	b.	For the Loss Block enter “los” into the console 
		(EyeLinks EDF files can only be 8 characters max. Do not attemt to change this. EyeLink will crash otherwise and Eye-Tracking data will not be saved.)

4.	The task will then set up with the Eye-Tracker and go straight to the Calibration screen. 

	a.	Setup the participant and eye-tracker following the guidelines in the Eye-Tracker Guide document and EyeLink User Manual.


5.	Run the task

	a.	Go to the Recording screen by pressing the escape key. Initiate the task by pressing enter. The task will run starting with the Block that was entered in step 3.

	b.	After the first block is run, the task will go to a break screen allowing the participant to take a break for as long as they need. Press the Space Bar to continue the task.

	c.	The task will then enter the Calibration screen to perform another calibration, and then run the remaining block. Once the task is finished it will go to an END SCREEN. Press “e” on the end screen to save out the data and end the experiment. 

6.	Convert the .edf files to .asc text files for processing using EyeLinks conversion tool, and upload all the data to the Google Drive. 


NOTE: For the 2 Stimulus task the Stimuli are coded specifically as described below and is consistent for both the WIN and LOSS Blocks.
	- 1 = LEFT
	- 2 = RIGHT



