# about -------------------------------------------------------------------
# this file cleans the targeting data
# input: data.csv
# output: targeting_data.dta
# author: @lrdegeest


# dependencies ------------------------------------------------------------
library(tidyverse)
library(readstata13)

# pseudocode --------------------------------------------------------------

# 1. setup: create list of dataframes (one per unique treatment+session+group)
## returns: data_list_1

# 2. reshape the sanctions in each dataframe
## returns: data_list_2

# 3. get the target investments
## returns: data_list_3

# 4. combine all the new dataframes and export
## returns: df_all
## exports: .csv and .dta files

# 1. set up ------------------------------------------------------------------
df <- read.csv("~/Google Drive/research_gdrive/hetero_cpr/data/data.csv")
df <- df[,!grepl(names(df),pattern = "X")] # get rid of extra columns
df$GameID <- 100*df$Homo + 10*df$Session + df$GameID # 16 unique groups
df_pun <- subset(df, FF == 1) # only punishment data

# data list that will contain a dataframe for each unique group
data_list <- list() # empty list
for(i in unique(df_pun$GameID)) {
  dsub <- subset(df_pun, GameID == i) # subset dataframe containing only that group
  df_name <- paste("dfGroup", i, sep="") # update the name of the dataframe
  data_list[[df_name]] <- dsub # add the dataframe to the list
}
## sanity check
length(data_list) # should be 16
table(sapply(data_list, nrow)) # should have 64 rows per group (4 subs per group * 16 periods)

# 2. get sanctions --------------------------------------------------------
get_target_sanctions <- function(d, n_periods = 16, groupsize=4) { # argument is a dataframe for a unique group
  d_target <- d[,12:15]
  targeting <- as.numeric(c(t(d_target))) # collapse all rows into a single column
  d <- d[rep(1:nrow(d),each=groupsize),] # duplicate rows 
  d$target_sanction <- targeting
  d$target <- rep(seq(1,4,1), n_periods*groupsize) # encode the targets
  d <- na.omit(d) # drop the NAs since subjects can't punish themselves
  d <- d %>% # now create the self IDs
    group_by(ProfileID,RoundID) %>% 
    mutate(self = sum(1:4) - sum(target))
  return(d)
}

# run the function
data_list_2 <- lapply(data_list, get_target_sanctions)
table(sapply(data_list_2, nrow)) # sanity check: each df should now have 16 periods * 4 subs * 3 rows per sub = 192 rows

# get investments and endowments ------------------------------------------
get_target_investment_endowment <- function(d){
  target_invest <- vector() # empty vector
  target_endow <- vector() # empty vector
  for(i in 1:nrow(d)) { # for each row
    t <- d$target[i] # get the current target
    p <- d$RoundID[i] # get the current period
    dsub <- subset(d, RoundID == p & self == t) # shrink the data to the current period and target
    invest <- dsub$Invest[1] # extract the investment
    target_invest <- append(target_invest, invest) # add it to the vector
    endow <- dsub$Token[1] # extract the endowment
    target_endow <- append(target_endow, endow) # add it to the vector
  }
  d$target_invest <- target_invest # add vector to data frame
  d$target_endow <- target_endow # add vector to data frame
  return(d)
}

# run the function
data_list_3 <- lapply(data_list_2, get_target_investment_endowment)

# combine  ------------------------------------------------------
df_all <- do.call(rbind, data_list_3)
nrow(df_all) # should be 16 groups * 16 periods * 4 subs * 3 rows per sub = 3072 rows
table(table(df_all$ProfileID)) # 64 subjects, 16*3=48 rows per subject
df_all <- df_all %>% # lag sanctions
  filter(RoundID > 1) %>% # first period is practice
  arrange(GameID,ProfileID,RoundID) %>% 
  group_by(ProfileID) %>% 
  mutate(Received = as.numeric(as.character(Received))) %>% 
  mutate(lagsanctioncost = dplyr::lag(Received, n = 3)) %>% # need to convert factor to numeric
  mutate(lagsanctioncost = as.numeric(as.character(lagsanctioncost)))
df_all$paid <- as.numeric(as.character(df_all$paid))
names(df_all) <- tolower(names(df_all))

# export ------------------------------------------------------------------
readstata13::save.dta13(df_all, file = "~/Google Drive/research_gdrive/hetero_cpr/data/targeting_data.dta", data.label = "CPR targeting data (sender to target)", convert.factors = F)