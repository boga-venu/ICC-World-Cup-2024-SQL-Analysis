use ICC2024;

-- Checck the details of the tables
 
select * from matches limit 10;

select * from Deliveries limit 10;

-- Types of Matches in the Tournament

select match_type,count(match_type) as No_Of_Matches from matches
group by match_type;

-- Match Wise Team Performnce Information  

select match_id as Match_no, innings, batting_team, bowling_team, 
sum(runs_off_bat)+sum(extras) as Total_runs, 
count(wicket_type) as wickets,
sum(case when runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
sum(case when wides is not null then 1 else 0 end) as Total_Wides,
ifnull(sum(extras)-sum(wides),0) as Other_Extras,
round((sum(runs_off_bat)+sum(extras))/20,2) as RunRate_per_Over
from deliveries
group by match_id,innings,batting_team, bowling_team;

-- Match Wise Team Performnce Information along with Winning Team

-- create view match_info as                            -- creating a view on the data obtained from this code to use in furthur analysis
select d.match_id as Match_no, d.innings, d.batting_team, d.bowling_team, 
count(*) as Balls_Faced,
sum(d.runs_off_bat)+sum(d.extras) as Total_runs, 
count(d.wicket_type) as wickets,
sum(case when d.runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when d.runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
sum(case when d.wides is not null then 1 else 0 end) as Total_Wides,
ifnull(sum(d.extras)-sum(d.wides),0) as Other_Extras,
round((sum(d.runs_off_bat)+sum(d.extras))/(count(batting_team)/6),2) as RunRate_per_Over,
m.winner as Winning_Team
from deliveries d
join matches m on
m.match_number = d.match_id
group by d.match_id,d.innings,d.batting_team, d.bowling_team,m.winner
having innings <= 2;

-- Team Performace

select batting_team as Team, count(distinct match_no) As Matches_Played, 
sum(case when batting_team = winning_team then 1 else 0 end) as Total_Wins,
(count(distinct match_no) - sum(case when batting_team = winning_team then 1 else 0 end)) as Total_Loses,
sum(total_runs) as Total_Runs
from match_info
group by batting_team
order by Total_Wins desc;

-- drop view match_info;             -- if incase we want to drop the view we can use this 

 -- Performace metrics According to Venue

select venue,  count(distinct match_id) as No_of_Matches,
sum(runs_off_bat)+sum(extras) as Total_runs,
sum(case when runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
count(Wicket_type) As Total_Wickets,
round((sum(runs_off_bat)+sum(extras))/count(distinct match_id),0) as Avg_Runs_Per_Match,
round(count(Wicket_type)/count(distinct match_id),0) as Avg_Wickets_Per_Match
from deliveries
group by venue
order by total_runs desc,Total_wickets desc;

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

# Players Batting performance Information

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

# Indian Players Batting performance Information

select striker as Player , batting_team as Team,
sum(runs_off_bat)+sum(extras) as Total_runs,
count(distinct match_id) as Innings_Played,
sum(case when runs_off_bat = 6 then 1 else 0 end) as No_of_Sixes,
sum(case when runs_off_bat = 4 then 1 else 0 end) as No_of_Fours,
round((sum(runs_off_bat)+sum(extras))/(count(striker)/6),2) as Run_Rate,
round((sum(runs_off_bat)+sum(extras))/(count(striker)/100),2) as Strike_Rate,
round((sum(runs_off_bat)+sum(extras))/count(distinct match_id),2) as Batting_AVG
from deliveries
group by striker, batting_team
having Team = "India"
order by sum(runs_off_bat)+sum(extras) desc;

# Player Bowling performance Information

	-- Main Info
select Bowler as Player, bowling_team as Team,
count(Wicket_type) As Wickets_Taken,
sum(runs_off_bat)+sum(extras) as Runs_Given,
sum(extras) As Extras,
ifnull(round((sum(runs_off_bat)+sum(extras))/count(wicket_type),2),0) as Bowling_Avg
from deliveries
group by Bowler,bowling_team
order by count(Wicket_type) desc;

	-- Maiden Overs Info
    
select bowler, count(bowler) as Maiden_Overs from 
(select match_id, bowler, Ceil(ball), sum(runs_off_bat)+sum(extras), count(bowler)
from deliveries
group by match_id, bowler, Ceil(ball)
having sum(runs_off_bat)+sum(extras) = 0 and count(bowler) = 6) as Maiden_Info
group by bowler
order by count(bowler) desc;

  -- Overall Information
 
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

-- Wickets Taken in the tournament
 
select wicket_type, count(wicket_type) as No_of_Wickets
from deliveries
group by wicket_type
having wicket_type is not null
order by no_of_Wickets desc;

# Indian Players Bowling performance Information

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
on PInfo.Player = MInfo.bowler
having pinfo.team = "India";



