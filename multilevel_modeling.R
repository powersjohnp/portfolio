# This script runs a series of multilevel models to test the significance of level 1 predictors.  
# It outputs a .csv file with the coefficients for the predictors as well as confidence intervals for these coefficients.  

# general setup
library(lme4)
library(dplyr)
library(lmerTest)


# ... CODE OMITTED


# read the data
mlm_data = read.csv("../../data/multilevel_data2.csv")

## overall communication models
# group mean center level 1 variables
mlm_data = mlm_data %>%
  group_by(ID) %>%
  mutate(change_text.c = change_text - mean(change_text, na.rm = TRUE),
         change_voice.c = change_voice - mean(change_voice, na.rm = TRUE),
         change_video.c = change_video - mean(change_video, na.rm = TRUE),
         change_person.c = change_person - mean(change_person, na.rm = TRUE),
         change_overall.c = change_overall - mean(change_overall, na.rm = TRUE),
         prior_freq_text.c = prior_freq_text - mean(prior_freq_text, na.rm = TRUE),
         prior_freq_voice.c = prior_freq_voice - mean(prior_freq_voice, na.rm = TRUE),
         prior_freq_video.c = prior_freq_video - mean(prior_freq_video, na.rm = TRUE),
         prior_freq_person.c = prior_freq_person - mean(prior_freq_person, na.rm = TRUE),
         prior_freq_overall.c = prior_freq_overall - mean(prior_freq_overall, na.rm = TRUE)) %>%
  ungroup()

## reapp models
# reapp models with random intercept (null models)
# (REML accounts for fixed effects when estimating random effects to reduce bias, especially advisable with smaller samples
# however, you cannot use a likelihood ratio test to compare models with REML unless they have the same fixed effects)
model_reapp_text_null = lmer(helpful_reapp_text ~ (1|ID), REML = TRUE, data = mlm_data)
model_reapp_voice_null = lmer(helpful_reapp_voice ~ (1|ID), REML = TRUE, data = mlm_data)
model_reapp_video_null = lmer(helpful_reapp_video ~ (1|ID), REML = TRUE, data = mlm_data)
model_reapp_person_null = lmer(helpful_reapp_person ~ (1|ID), REML = TRUE, data = mlm_data)
model_reapp_overall_null = lmer(helpful_reapp_overall ~ (1|ID), REML = TRUE, data = mlm_data)

# check intraclass correlation coefficients of null models, in this case > .05 supports use of MLM
# all models with the current script and data have values > .2
compute_icc(model_reapp_text_null)
compute_icc(model_reapp_voice_null)
compute_icc(model_reapp_video_null)
compute_icc(model_reapp_person_null)
compute_icc(model_reapp_overall_null)

# reapp models with prior predictors
model_reapp_text_prior_text = lmer(helpful_reapp_text ~ prior_freq_text.c + (1|ID), REML = TRUE, data = mlm_data)
model_reapp_voice_prior_voice = lmer(helpful_reapp_voice ~ prior_freq_voice.c + (1|ID), REML = TRUE, data = mlm_data)
model_reapp_video_prior_video = lmer(helpful_reapp_video ~ prior_freq_video.c + (1|ID), REML = TRUE, data = mlm_data)
model_reapp_person_prior_person = lmer(helpful_reapp_person ~ prior_freq_person.c + (1|ID), REML = TRUE, data = mlm_data)
model_reapp_overall_prior_overall = lmer(helpful_reapp_overall ~ prior_freq_overall.c + (1|ID), REML = TRUE, data = mlm_data)


# ... CODE FOR ADDITIONAL MODELS OMITTED


# summarize results in a data frame
CI_df = data.frame(ls(pattern = "model_"))
CI_df %>% mutate_if(is.factor, as.character) -> CI_df
colnames(CI_df) = "model"
CI_matrix = matrix(data = NA, nrow = nrow(CI_df), ncol = 2)

# compute confidence intervals for the coefficient of the predictor of interest
for (i in 1:nrow(CI_df)) {
  CI_temp = confint(get(CI_df[i,1]))
  CI_matrix[i,] = CI_temp[nrow(CI_temp),]
}
CI_df$CI_LL = CI_matrix[,1]
CI_df$CI_UP = CI_matrix[,2]

# write data frame to CSV file
write.csv(CI_df, "PAN_models_CIs.csv", row.names = FALSE)
