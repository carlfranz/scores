# Scores
## Introduction
Simple scripts and queries for scorekeeping.

Supports:
* multi season through environment variable 
* home and away support
* differences am and pm games

Sample:
```
Stats for season 4
Player        G    V    N    S   GF   GS  +/- P.ti 
----------------------------------------------------
Luca         15    8    5    2   40   27   13   29 
Mohsen       15    8    4    3   34   27    7   28 
Riccardo     15    4    5    6   32   36   -4   17 
Carlo        15    2    2   11   18   34  -16    8
```

## Configuration
Create a sqlite database named `results.db` and run this create query.

```
CREATE TABLE scores ( 
	id INTEGER PRIMARY KEY ASC, 
	home TEXT, 
	away TEXT, 
	home_score  INT, 
	away_score INT,
	d_date TEXT, 
	shift TEXT, 
	season integer
);
```

Map player to character shortcut `insert.pl` file.

```
my %replaces = (
  q{R} => "Riccardo",
  q{M} => "Mohsen",
  q{C} => "Carlo",
  q{L} => "Luca"
);
```

## Usage
Insert a score:

    env GOAL3X_SEASON=1 perl insert.pl R L 99 99 PM

View statistics for season (*Warning! env variable must be set*)

    ./stats.pl



