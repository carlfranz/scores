.mode html
.header on


select home as GAMER1, away as GAMER2, home_score as GOAL1, away_score as GOAL2 
from scores
where d_date = DATE()
