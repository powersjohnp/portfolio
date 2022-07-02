# simple correlation analyses with accompanying plots 

# general setup
library(ggplot2)

# set working directory
setwd("S:/Research Projects/Cross_CAREER/analyses")

# read the data
data = read.csv("../data/cross_self_report.csv")

# run the correlation test
cor.test(data$ERQ_R, data$ITOE, method = "pearson")
cor.test(data$ERQ_R, data$reapp_success, method = "pearson")
cor.test(data$ITOE, data$reapp_success, method = "pearson")

# create scatter plots with regression line and save
ggplot(data, aes(x = ERQ_R, y = ITOE)) + 
  geom_point(size = 3) +
  geom_smooth(method = lm, size = 2)

ggsave('ERQ_R_ITOE.png',dpi=300)

ggplot(data, aes(x = ERQ_R, y = reapp_success)) + 
  geom_point(size = 3) +
  geom_smooth(method = lm, size = 2)

ggsave('ERQ_R_reapp_success.png',dpi=300)

ggplot(data, aes(x = ITOE, y = reapp_success)) + 
  geom_point(size = 3) +
  geom_smooth(method = lm, size = 2)

ggsave('ITOE_reapp_success.png',dpi=300)