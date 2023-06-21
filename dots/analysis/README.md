This is where code and outputs related to any analyses (choice, RT, eyetracking, fmri, computational models) would go.

At minimum (i.e. if a Docker image for the project has not yet been created) this should contain some information on the libraries/packages and their versions required to run the code.

For R a most primitive way of doing this would be `sessionInfo()`

For python one rudimentary way would be `pip freeze > requirement.txt`

`helpers`: for general purpose functions used in various notebooks, preprocessing steps etc.  
`notebooks`: interim analyses. Once finalized in notebooks, clean versions of this code can be copied to standalone scripts in `preprocessing` and`submitted_analyses`  
`outputs`: for all outputs including figures, simulations, knitted notebooks etc.  
`preprocessing`: for self-contained scripts that modify data for further analyses  
`submitted_analyses`: for self-contained scripts that contain the code reproducing analyses in any submission.  