# ICC-World-Cup-2024-SQL-Analysis
This project contains SQL queries and analyses for the ICC World Cup 2024 tournament. It includes data exploration, match analysis, team and player performance metrics, and venue-specific performance evaluations.

## Table of Contents

- [Introduction](#introduction)
- [Objectives](#objectives)
- [Project Structure](#project-structure)
- [Data Overview](#data-overview)
- [SQL Queries and Analysis](#sql-queries-and-analysis)
  - [Data Exploration](#data-exploration)
  - [Match Types Analysis](#match-types-analysis)
  - [Team Performance](#team-performance)
  - [Player Performance](#player-performance)
  - [Venue Analysis](#venue-analysis)
  - [Other Metrics](#other-metrics)
- [Methodologies](#methodologies)
- [Results and Insights](#results-and-insights)
- [Technologies Used](#technologies-used)
- [How to Use](#how-to-use)

## Introduction

This project involves analyzing data from the ICC World Cup 2024 tournament to derive insights on match types, team performance, player statistics, and venue metrics using SQL.

## Objectives
- Analyze different types of matches in the tournament.
- Evaluate team and player performance metrics.
- Assess venue-specific performance data.

## Project Structure

The repository includes the following files:
- `Data Folder`: Contains sourse data files.
- `Data Tables.sql`: Contains database and Data tables based on sourse data.
- `ICC 2024 Analysis.sql`: Contains all the SQL queries used for data analysis.

## Data Overview

The data used in this project includes:
- **Matches Table**: Details of each match played in the tournament.
- **Deliveries Table**: Ball-by-ball data for each match.

## SQL Queries and Analysis

### Data Exploration

#### Checking the details of the tables:

  ```sql
  -- Check the details of the tables
  select * from matches limit 10;
  select * from deliveries limit 10;
  ```
### Match Types Analysis

#### Analyze the different types of matches in the tournament:
  ```sql
  -- Types of Matches in the Tournament
  select match_type, count(match_type) as No_Of_Matches
  from matches
  group by match_type;
  ```
### Team Performance

#### Analyze match-wise team performance information:
```sql
-- Match Wise Team Performance Information  
select match_id as Match_no, innings, batting_team, bowling_team, 
sum(runs_off_bat) + sum(extras) as Total_runs, 
count(wicket_type) as wickets,
sum(case when runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
sum(case when wides is not null then 1 else 0 end) as Total_Wides,
ifnull(sum(extras) - sum(wides), 0) as Other_Extras,
round((sum(runs_off_bat) + sum(extras)) / 20, 2) as RunRate_per_Over
from deliveries
group by match_id, innings, batting_team, bowling_team;
```
#### Team performance with winning team data:
```sql
-- Match Wise Team Performance Information along with Winning Team
-- Create view match_info as   --uncomment this to create a view of this output to use in furthur analysis
select d.match_id as Match_no, d.innings, d.batting_team, d.bowling_team, 
count(*) as Balls_Faced,
sum(d.runs_off_bat) + sum(d.extras) as Total_runs, 
count(d.wicket_type) as wickets,
sum(case when d.runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when d.runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
sum(case when d.wides is not null then 1 else 0 end) as Total_Wides,
ifnull(sum(d.extras) - sum(d.wides), 0) as Other_Extras,
round((sum(d.runs_off_bat) + sum(d.extras)) / (count(batting_team) / 6), 2) as RunRate_per_Over,
m.winner as Winning_Team
from deliveries d
join matches m on m.match_number = d.match_id
group by d.match_id, d.innings, d.batting_team, d.bowling_team, m.winner
having innings <= 2;
```
#### Team performance metrics:
```sql
-- Team Performance
select batting_team as Team, count(distinct match_no) As Matches_Played, 
sum(case when batting_team = winning_team then 1 else 0 end) as Total_Wins,
(count(distinct match_no) - sum(case when batting_team = winning_team then 1 else 0 end)) as Total_Loses,
sum(total_runs) as Total_Runs
from match_info
group by batting_team
order by Total_Wins desc;
```

### Player Performance

#### Players Batting performance:

```sql
-- Players Batting performance Information
select striker as Player , batting_team as Country,
sum(runs_off_bat)+sum(extras) as Total_runs,
count(distinct match_id) as Innings_Played,
sum(case when runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
round((sum(runs_off_bat)+sum(extras))/(count(striker)/6),2) as Run_Rate,
round((sum(runs_off_bat)+sum(extras))/(count(striker)/100),2) as Strike_Rate,
round((sum(runs_off_bat)+sum(extras))/count(distinct match_id),2) as Batting_AVG
from deliveries
group by striker, batting_team
order by sum(runs_off_bat)+sum(extras) desc;
```
#### Player Bowling performance
```sql
-- Player Bowling performance Information
select PInfo.Player,PInfo.Team, PInfo.Wickets_Taken, PInfo.Runs_Given, PInfo.Extras,PInfo.Bowling_Avg, 
ifnull(MInfo.Maiden_Overs,0) as Maiden_Overs
from 
(select Bowler as Player , 
bowling_team as Team,
count(Wicket_type) As Wickets_Taken,
sum(runs_off_bat)+sum(extras) as Runs_Given,
sum(extras) As Extras,
ifnull(round((sum(runs_off_bat)+sum(extras))/count(wicket_type),2),0) as Bowling_Avg
from deliveries
group by Bowler,Team
order by count(Wicket_type) desc) as PInfo
left join 
(select bowler, count(bowler) as Maiden_Overs from 
(select match_id, bowler, Ceil(ball), sum(runs_off_bat)+sum(extras), count(bowler)
from deliveries
group by match_id, bowler, Ceil(ball)
having sum(runs_off_bat)+sum(extras) = 0 and count(bowler) = 6) as Maiden_Info
group by bowler
order by count(bowler) desc) as MInfo
on PInfo.Player = MInfo.bowler;
```
### Venue Analysis

#### Performance metrics according to the venue:
```sql
-- Performance Metrics According to Venue
select venue, count(*) as Matches_Played, sum(runs_off_bat) as Total_Runs, sum(wickets) as Total_Wickets
from matches m
join deliveries d on m.match_number = d.match_id
group by venue;
```
### Other Metrics

#### Performance according to toss_decision
```sql
-- Performance according to toss_decision 
select toss_winner as team, count(toss_winner) as no_tossWins,
sum(case when toss_decision = "field" then 1 else 0 end) as choosed_to_Field,
sum(case when toss_decision = "Bat" then 1 else 0 end) as choosed_to_Bat,
sum(case when toss_winner = winner then 1 else 0 end) as toss_and_match_wins,
round((sum(case when toss_winner = winner then 1 else 0 end)/
count(toss_winner)*100),2) as toss_to_win_Percentage
from matches
group by toss_winner 
order by count(toss_winner) desc;
```
#### Wickets Taken in the tournament
```sql
-- DIfferent Wicket types Taken in the tournament
select wicket_type, count(wicket_type) as No_of_Wickets
from deliveries
group by wicket_type
having wicket_type is not null
order by no_of_Wickets desc;
```


## Methodologies
- **Data Aggregation**: Used SQL queries to aggregate data on match types, runs, wickets, and more.
- **Performance Metrics**: Calculated batting and bowling averages, strike rates, and economy rates.
- **Select Statements**: Used advanced concepts of select statements such as case to get selective information.
- **Joins and Subqueries**: Leveraged joins and subqueries to combine data from multiple tables for comprehensive analysis.

## Results and Insights

- Match Types: Identified the distribution of match types in the tournament.
- Team Performance: Analyzed team performance in terms of matches played, wins, losses, and total runs.
- Player Performance: Evaluated key player statistics like runs scored, wickets taken, and economy rates.
- Venue Analysis: Identified detailed performance information in different venues in the tournament.

## Technologies Used

- SQL
- MySQL
- MySQL Workbench

## How to Use

1. Download all the files from repository
2. Load the `Data tables.sql` file into MySQL Workbench.
3. Execute all the queries to create database and the necessary tables.
4. Load the `ICC 2024 Analysis.sql` file.
5. Execute the queries to perform the analysis.
