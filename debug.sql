SELECT sum(away_score) 
FROM scores 
WHERE home like 'Luca' and season = 3;

SELECT sum(home_score)
FROM scores
WHERE away like 'Luca' and season = 3;
