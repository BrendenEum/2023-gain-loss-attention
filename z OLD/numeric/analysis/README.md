This is where code and outputs related to any analyses (choice, RT, eyetracking, fmri, computational models) would go.

At minimum (i.e. if a Docker image for the project has not yet been created) this should contain some information on the libraries/packages and their versions required to run the code.

For R a most primitive way of doing this would be `sessionInfo()`

For python one rudimentary way would be `pip freeze > requirement.txt`

`helpers`: for general purpose functions used in various notebooks, preprocessing steps etc.  
`notebooks`: interim analyses. Once finalized in notebooks, clean versions of this code can be copied to standalone scripts in `preprocessing` and`submitted_analyses`  
`outputs`: for all outputs including figures, simulations, knitted notebooks etc.  
`preprocessing`: for self-contained scripts that modify data for further analyses  
`submitted_analyses`: for self-contained scripts that contain the code reproducing analyses in any submission.  

------------------------------------------------------------------------------

Everything will run through a virtual machine in order to ensure quick and easy reproducibility. When the project is near finished, I'll write a *_clusternotes.md file that walks you step-by-step through the entire analysis pipeline.

Everything is in the order it needs to be run

Author: Brenden Eum (2023)

1. preprocessing/cleanPsychopyData_local.R
   1. Clean data and generate new variables
2. NB1 - Model Free Analyses.Rmd
3. NB2 - Causal Effects of Fixation Cross Location.Rmd