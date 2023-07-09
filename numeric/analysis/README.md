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

For now, this will be a series of separate clusternotes, in the order that it needs to be run.

Author: Brenden Eum (2023)


1. helpers/cluster_scripts/preprocessing_clusternotes.md

    * Run this locally on your computer through a virtual machine. It doesn't take long and doesn't need a lot of computing power.

2. helpers/cluster_scripts/modelfree_clusternotes.md

    * Run this locally on your computer through a virtual machine. It doesn't take long and doesn't need a lot of computing power.