# portfolio
Example excerpts from code I have written for research projects  

### R  
data_summary.R  
This script extracts data from research task log files and saves a summarized form of these data to a .csv file for analysis.  

### MATLAB  
task_pseudorandomization.m  
This script performs trial order pseudorandomization for a research task with a complex design, in which many conditions had to be balanced and ordered in very specific ways. It was called at the beginning of a task script, when research participants completed said task while undergoing fMRI scanning of brain activity.  

research_task.m  
This function runs a research task using the PsychToolBox package for MATLAB. Research participants completed this task, which involved viewing images and making ratings, while undergoing fMRI scanning of brain activity.  

discrete_sampling.m  
This function generates a set of values from a discrete distribution that matches various user-specified criteria. It was used to generate a variable that is needed for fMRI research task designs.   

### BASH  
data_extraction.sh  
This script extracts data from log files that were generated while participants completed a research task in an MRI scanner. These data are then reconstructed into files that will be used for analyses of brain activity.
