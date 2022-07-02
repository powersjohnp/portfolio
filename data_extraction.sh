#!/bin/bash

# This script creates files needed for fMRI analysis. The AFNI software that will be used for the fMRI analysis calls these "stim files."
# These files contain detailed information about when different types of events occurred during the task participants completed in the MRI scanner.
# All of this information must be extracted from log files created by the task script and reconstructed into these stim files that AFNI can use.

# The script reads a text file (stim_files_list.txt) that contains space-separated lists of subject IDs, order numbers, and run numbers.
# It then finds files with names matching these features in the directory $data_dir and creates an output directory for each participant's stim files.
# It then writes FSL-style stim files for each event type by extracting the appropriate data from the timing data files.
# A corresponding script on the computing cluster (create_stim_files_rdac.sh) will later convert these stim files from FSL-style to AFNI format. 

# event types include cue, self_look_neu, self_look_neg, self_change_neg, other_look_neu, other_look_neg, other_change_neg, rate_aff, rate_diff, relax/ITI, self, other
# the following details are used to locate the data for each of these event types
# cue is 5th column all rows, duration 2 seconds
# look_neu is 3rd column=2, duration 7
# look_neg is 3rd column=1 & 4th column=2, duration 7
# change_neg is 4th column=1, duration 7
# rate_aff is 7th column when not equal to 0, duration 3
# rate_diff is 9th column when not equal to 0, duration 3
# relax/ITI is 11th and 12th columns all rows 
# self is 5th column of first row, duration = 11th column of last row - 5th column of first row, for even run numbers when order=1 and odd run numbers when order=2
# other is 5th column of first row, duration = 11th column of last row - 5th column of first row, for odd run numbers when order=1 and even run numbers when order=2 

# define data directory
data_dir='main_task'

# create variable for ID
# in loop, ID variable will be used to determine when new stim files should be created for the next participant
id=$(cat stim_files_list.txt | awk '{print $1}' | head -n 1)

# create a new directory in the data directory where the first participant's stim files will be stored
mkdir ${data_dir}/${id}

# loop through all timing files listed in stim_files_list.txt 
cat stim_files_list.txt | while read line; do
	
	order=$(echo $line | awk '{print $2}')
	run=$(echo $line | awk '{print $3}')

	# check whether the current line of stim_files_list.txt matches the current participant or begins a new participant
	if [ `echo $line | awk '{print $1}'` != ${id} ]; then
		
		# we're starting a new participant, so update id and create a directory for this participant's stim files
		id=$(echo $line | awk '{print $1}')
		mkdir ${data_dir}/${id}
	fi
	
	# write stim file for cue 
	cat ${data_dir}/ROSEF_timing_${id}_${order}_${run}.txt | awk 'NR>1 {print $5, 2, 1}' > ${data_dir}/${id}/cue_run${run}.txt
	
	# write stim file for rate_aff
	cat ${data_dir}/ROSEF_timing_${id}_${order}_${run}.txt | awk 'NR>1 {if ($7!=0) {print $7, 3, 1}}' > ${data_dir}/${id}/rate_aff_run${run}.txt
	
	# write stim file for rate_diff
	cat ${data_dir}/ROSEF_timing_${id}_${order}_${run}.txt | awk 'NR>1 {if ($9!=0) {print $9, 3, 1}}' > ${data_dir}/${id}/rate_diff_run${run}.txt
	
	# write stim file for relax
	cat ${data_dir}/ROSEF_timing_${id}_${order}_${run}.txt | awk 'NR>1 {print $11, $12, 1}' > ${data_dir}/${id}/relax_run${run}.txt
		
	# special operations for writing self and other stim files
	event_time=$(cat ${data_dir}/ROSEF_timing_${id}_${order}_${run}.txt | awk '{if(NR==2) print $5}')
	event_duration=$(echo "`cat ${data_dir}/ROSEF_timing_${id}_${order}_${run}.txt | awk 'END {print $11}'` - ${event_time}" | bc)
	
	# ... CODE OMITTED
	
done 
