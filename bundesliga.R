library(rjson)
library(reshape2)
library (plyr)
options(stringsAsFactors=FALSE)

json_file <- "http://openligadb-json.heroku.com/api/matchdata_by_group_league_saison?group_order_id=17&league_saison=2013&league_shortcut=bl1"
json_data <- fromJSON(paste(readLines(json_file, warn=FALSE), collapse=""))

spiel <- json_data[[1]][[9]]

spiel[c('name_team1', 'name_team2')]
tore <- spiel[['goals']][[1]]
tmp <- lapply(tore, "[", c('goal_match_minute', 'goal_score_team1', 'goal_score_team2'))
tore.df <- ldply(tmp, data.frame)

tore.df[tore.df$goal_match_minute < 80, ]
