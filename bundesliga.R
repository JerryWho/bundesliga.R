library(rjson)
library(reshape2)
library (plyr)
options(stringsAsFactors=FALSE)

url.template <- "http://openligadb-json.heroku.com/api/matchdata_by_group_league_saison?league_saison=2013&league_shortcut=bl1&group_order_id="
gamedays <- seq(1:19)

data <- list()

for(gameday in gamedays){
  url <- paste0(url.template, gameday)
  json_data <- fromJSON(paste(readLines(url, warn=FALSE), collapse=""))
  data[[gameday]] <- json_data
}
save(data, file="data.Rda")


load("data.Rda")

getPoints <- function(goals.df, minute=120, team=1){
  goals <- 
  
}


match <- data[[17]][[1]][[9]]

match[c('name_team1', 'name_team2')]
goals <- match[['goals']][[1]]
tmp <- lapply(goals, "[", c('goal_match_minute', 'goal_score_team1', 'goal_score_team2'))
goals.df <- ldply(tmp, data.frame)
goals.df[, 1:3] <- sapply(goals.df[,1:3], as.integer)

goals.df[goals.df$goal_match_minute < 80, ]
goals.df[goals.df$goal_match_minute < 120, ]
