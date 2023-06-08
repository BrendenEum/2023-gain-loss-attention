# About

This is an effort to create a general template for most projects

# To resolve

- The minimal amount of library/package info

- Narrative overview of code and the order it is ought to be run in
    - Would a README be a good place to put that info? But one README per directory is unlikely to be enough

- What should the `run_all_analyses.R` script and its outputs look like?

- Different type of projects: e.g. theoretical/simulation based, meta-analyses

- Data version control
    - Do we want to use tools designed for ML https://neptune.ai/blog/best-data-version-control-tools
    - Or something that is more focused on research https://www.datalad.org/

- Linking files in raw_data to code/collection procedure that collected it in experiment
    - How about adding column to raw_data that contains at least the script name and preferably some sort of hash associated with the version experiment code script
    - What would this look like for the different methods we use e.g. Gorilla vs. Psychopy vs. Psychtoolbox etc.

# Resources

[Chapter on project management from open textbook on Experimental Methods](https://experimentology.io/13-management)  

[A practical guide for transparency in psychological science](https://psych-transparency-guide.uni-koeln.de/)

[The Practice of Reproducible Research: Case Studies and Lessons from the Data-Intensive Sciences](http://www.practicereproducibleresearch.org/)  

[Stanford CORES: Open By Design](https://dsi-cores.github.io/OpenByDesign/README.html)  
    - Brief descriptions with links to many resources  

[NASA: Transform to Open Science](https://nasa.github.io/Transform-to-Open-Science-Book/About/About-Announcements.html)  

[Easing Into Open Science: A Gudie for Graduate Students and their Advisors](https://psyarxiv.com/vzjdp/)
    - Short paper with step by step guide  

[TIER: Teaching Integrity in Empirical Reasearch](https://www.projecttier.org/)
    - Specifically the [protocol](https://www.projecttier.org/tier-protocol/protocol-4-0/)  
    - Lots of teaching materials as well  
