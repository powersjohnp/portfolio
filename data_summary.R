# extracting data from research task log files, summarizing, and saving to a .csv file for analysis

library(dplyr)

setwd("S:/Research Projects/ROSE_fMRI/data/main_task/")

# create a list of all data files in the directory
file_list = list.files(pattern = "^ROSEF_data")

# create a data frame that will store participant ID, order #, and run # as separate variables
file_details = data.frame(matrix(ncol = 3, nrow = length(file_list)))
colnames(file_details) = c("ID", "ORDER", "RUN")

# read the list of filenames and populate the data frame file_details accordingly
for(i in 1:length(file_list)) {
  file_details[i, 1] = sub("_.*", "", sub("ROSEF_data_", "", file_list[i]))
  file_details[i, 2] = substr(file_list[i], start = nchar(file_list[i])-6, stop = nchar(file_list[i])-6)
  file_details[i, 3] = substr(file_list[i], start = nchar(file_list[i])-4, stop = nchar(file_list[i])-4)
}

# concatenate data from all files into a single data frame
data = data.frame(matrix(ncol = 9, nrow = 0))

for(i in 1:length(file_list)) {
  
  data_run = read.table(paste("ROSEF_data_", file_details[i, 1], "_", file_details[i, 2], "_", file_details[i, 3], ".txt", sep = ""), header = TRUE)
  data_run = mutate(data_run, ORDER = file_details[i, 2]) # add column for order 
  data_run = mutate(data_run, RUN = file_details[i, 3]) # add column for run 
  data = rbind(data, data_run)
  
}

# add a column where 1 = self condition and 0 = other condition
data$SELF = 0
data$SELF[(data$ORDER == 1 & data$RUN %in% c(2,4,6)) | (data$ORDER == 2 & data$RUN %in% c(1,3,5))] = 1

# data frame to store participant means
data_summary = data.frame(ID=file_details$ID, resp_rate=NA, s_lookneu_aff=NA, 
                          s_lookneu_diff=NA, s_lookneg_aff=NA, s_lookneg_diff=NA, 
                          s_changeneg_aff=NA, s_changeneg_diff=NA, o_lookneu_aff=NA, 
                          o_lookneu_diff=NA, o_lookneg_aff=NA, o_lookneg_diff=NA, 
                          o_changeneg_aff=NA, o_changeneg_diff=NA)
data_summary = data_summary %>% distinct()

# compute response rates, store results to data_summary
response_data = data %>%
  group_by(SUBJ) %>%
  summarize(resp_rate = (sum(AFFECT > 0) + sum(DIFFICULTY > 0)) / sum(TRIAL > 0)) %>%
  ungroup()
data_summary$ID = response_data$SUBJ # grouping/ungrouping changes sorting of IDs, so need to update to match
data_summary$resp_rate = response_data$resp_rate

# subset data by affect and difficulty and self and other
aff_data = data[data$AFFECT > 0, ]
diff_data = data[data$DIFFICULTY > 0, ]
s_aff_data = aff_data[aff_data$SELF == 1, ]
o_aff_data = aff_data[aff_data$SELF == 0, ]
s_diff_data = diff_data[diff_data$SELF == 1, ]
o_diff_data = diff_data[diff_data$SELF == 0, ]

# compute other variables, store results to data_summary
s_aff_data_stats = s_aff_data %>%
  group_by(SUBJ) %>%
  summarize(s_lookneu_aff = mean(AFFECT[STIM_TYPE == 2]),
            s_lookneg_aff = mean(AFFECT[STIM_TYPE == 1 & CUE_TYPE == 2]),
            s_changeneg_aff = mean(AFFECT[CUE_TYPE == 1])) %>%
  ungroup()
data_summary$s_lookneu_aff = s_aff_data_stats$s_lookneu_aff
data_summary$s_lookneg_aff = s_aff_data_stats$s_lookneg_aff
data_summary$s_changeneg_aff = s_aff_data_stats$s_changeneg_aff


# ... CODE OMITTED


# write data frame to CSV file
write.csv(data_summary, "ROSEF_online_data_summary.csv", row.names = FALSE)
