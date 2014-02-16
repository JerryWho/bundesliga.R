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

# get the points and goals.for and goals.against for a given match from the beginning to the given minute
getPointsAndGoals <- function(match, minute=120){
    
  goals <- match[['goals']][[1]]
  tmp <- lapply(goals, "[", c('goal_match_minute', 'goal_score_team1', 'goal_score_team2'))
  goals.df <- ldply(tmp, data.frame)
  goals.df[, 1:3] <- sapply(goals.df[,1:3], as.integer)
  
  relevant.goals <- subset(goals.df, goal_match_minute <= minute)
  
  if(nrow(relevant.goals) == 0){
    # no goal yet
    relevant.goals <- data.frame(goal_match_minute=0, goal_score_team1=0, goal_score_team2=0)
  }
  
  last.relevant.goal <- max(relevant.goals$goal_match_minute)
  goal.at.minute <- subset(relevant.goals, goal_match_minute == last.relevant.goal)
  
  result <- list()
  
  if(goal.at.minute$goal_score_team1 == goal.at.minute$goal_score_team2){
    result[['team1']][['points']] <- 1
    result[['team2']][['points']] <- 1
  }

  if(goal.at.minute$goal_score_team1 > goal.at.minute$goal_score_team2){
    result[['team1']][['points']] <- 3
    result[['team2']][['points']] <- 0
  }
  
  if(goal.at.minute$goal_score_team1 < goal.at.minute$goal_score_team2){
    result[['team1']][['points']] <- 0
    result[['team2']][['points']] <- 3
  }

  result[['team1']][['goals.for']]     <- goal.at.minute$goal_score_team1
  result[['team1']][['goals.against']] <- goal.at.minute$goal_score_team2
  
  result[['team2']][['goals.for']]     <- goal.at.minute$goal_score_team2
  result[['team2']][['goals.against']] <- goal.at.minute$goal_score_team1
  
  result[['team1']][['name']]          <- match[c('name_team1')]
  result[['team2']][['name']]          <- match[c('name_team2')]
  return(result)
}

# Goal in additional time of first half
match <- data[[1]][[1]][[9]]

# Goal in additional time of second half
match <- data[[19]][[1]][[8]]

match[c('name_team1', 'name_team2')]
goals <- match[['goals']][[1]]
tmp <- lapply(goals, "[", c('goal_match_minute', 'goal_score_team1', 'goal_score_team2'))
goals.df <- ldply(tmp, data.frame)
goals.df[, 1:3] <- sapply(goals.df[,1:3], as.integer)

goals.df[goals.df$goal_match_minute < 80, ]
goals.df[goals.df$goal_match_minute < 120, ]

lapply(seq(from=0, to=100, by=10), FUN=function(x){getPointsAndGoals(match, x)})
