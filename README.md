CohortDiagnostics for UCB Refracture Study
========================================================================================================================================================
## Introduction
This repository contains the code for implementing cohort diagnostics for UCB Refracture Study led by the University of Oxford.

## To Run
1) Download this entire repository (you can download as a zip folder using Code -> Download ZIP, or you can use GitHub Desktop). 
2) Open the project <i>StudyCohortDiagnostics.Rproj</i> in RStudio (when inside the project, you will see its name on the top-right of your RStudio session)
3) Open and work though the <i>CodeToRun.R</i> file which should be the only file that you need to interact with. Run the lines in the file, adding your database specific information and so on (see comments within the file for instructions). The last line of this file will run the study <i>(source(here("RunStudy.R"))</i>.     
4) After running, please zip up the results folder by clicking More and Export and it is now ready to share.

## Changing/ adding cohort definitions
Cohort definitions are in the folder 1_InstantiateCohorts\Cohorts. Whatever cohorts are present in this folder will be run, with the file name used as the name for the cohort.
