# portfolio
Example excerpts from code I have written for research projects  

### Python  
self_injury_machine_learning.ipynb  
This Jupyter notebook demonstrates code I have written for a project using machine learning to study suicidality in adolescents. Although reduced for demonstration purposes, this notebook is relatively comprehensive, covering exploratory data analysis, preprocessing, modeling, and interpretation.  

analysis_and_figures.py  
This script preprocesses data from a research task to compute key measures. Basic regression analyses are then run using these measures and accompanying figures are produced. This script was designed to automate basic data summaries and analyses for periodic progress reports for a clinical trial.  

### R  
multilevel_modeling.R  
This script runs multilevel modeling analyses to test the significance of a level 1 predictor.  

data_summary.R  
This script extracts data from research task log files and saves a summarized form of these data to a .csv file for analysis.  

correlation_analyses.R  
This scripts runs simple correlation analyses and generates associated scatter plots with regression lines.  

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
