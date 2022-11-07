#1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.

SELECT * FROM IPL_BIDDER_POINTS;
SELECT * FROM ipl_bidding_details;
SELECT bidder_id,sum(BID_STATUS='won') FROM ipl_bidding_details group by bidder_id;
select * from ipl_bidder_points;

select ibd.BIDDER_ID, BIDDER_NAME, NO_OF_BIDS AS TOTAL_BIDS, SUM(BID_STATUS='won') AS BIDS_WON,
((SUM(BID_STATUS='won') / NO_OF_BIDS) * 100) as win_percentage
from ipl_bidding_details as ibd
join ipl_bidder_points as ibp
on ibd.BIDDER_ID= ibp.BIDDER_ID
join ipl_bidder_details as bd
on ibd.BIDDER_ID= bd.BIDDER_ID
group by ibd.BIDDER_ID
order by win_percentage desc;

#2.	Display the number of matches conducted at each stadium with stadium name, city from the database.

/*select * from ipl_match;
select * from ipl_match_schedule order by MATCH_ID;
select * from ipl_match_schedule where stadium_id =1;
select * from ipl_stadium;
*/
select ims.stadium_id, stadium_name, city, count( ims.stadium_id) as no_of_matches
from ipl_match_schedule as ims
join ipl_stadium as ist
on ims.STADIUM_ID = ist.STADIUM_ID
group by STADIUM_NAME;

/* select ims.stadium_id, stadium_name, city, count( distinct MATCH_ID) as no_of_matches
from ipl_match_schedule as ims
join ipl_stadium as ist
on ims.STADIUM_ID = ist.STADIUM_ID
group by STADIUM_NAME; */


#3. In a given stadium, what is the percentage of wins by a team which has won the toss?

select a.stadium_id,a.stadium_name ,a.wins,count(ms.stadium_id) as no_of_match,(wins/count(ms.stadium_id))*100 as "Win_Percent" 
from (select m.match_id,s.stadium_id,s.stadium_name,count(s.stadium_id) as "wins"
from ipl_stadium as s inner join ipl_match_schedule as ms
on s.stadium_id=ms.stadium_id
inner join ipl_match as m
on m.match_id=ms.match_id
where m.toss_winner=m.match_winner group by s.stadium_id)a 
inner join  ipl_match_schedule as ms
on a.stadium_id=ms.stadium_id
group by ms.stadium_id 
order by win_percent desc;

#4.	Show the total bids along with bid team and team name.

/* select * from ipl_bidder_details;
select * from ipl_team;
select * from ipl_bidding_details; */


select ibd.bidder_id, bidder_name as "bid team name", count(no_of_bids) as total_bids, team_name
from ipl_bidding_details as ibd
join ipl_bidder_points as ibp on ibd.BIDDER_ID = ibp.BIDDER_ID
join ipl_bidder_details as bd on ibd.BIDDER_ID = bd.BIDDER_ID
join ipl_team as itm on ibd.BID_TEAM = itm.TEAM_ID
group by team_name, bidder_name;

---------------------------------------------------------------------------
select a.bid_team,a.team_name,a.No_of_bids from
(select ibd.bid_team,t.team_name,count(ibd.bid_team ) as 'No_of_bids',(rank() over (order by count(ibd.bid_team )desc)) as "team"
from ipl_bidding_details as ibd inner join ipl_match_schedule as ims
on ibd.schedule_id=ims.schedule_id
inner join ipl_match as m
on m.match_id=ims.match_id
inner join ipl_team as t
on ibd.bid_team=t.team_id
group by ibd.bid_team order by count(ibd.bid_team) desc)a 
where a.team =1
union
select a.bid_team,a.team_name,a.No_of_bids from
(select ibd.bid_team,t.team_name,count(ibd.bid_team ) as 'No_of_bids',(rank() over (order by count(ibd.bid_team ))) as "team"
from ipl_bidding_details as ibd inner join ipl_match_schedule as ims
on ibd.schedule_id=ims.schedule_id
inner join ipl_match as m
on m.match_id=ims.match_id
inner join ipl_team as t
on ibd.bid_team=t.team_id
group by ibd.bid_team order by count(ibd.bid_team) desc)a 
where a.team in (1);




#5.	Show the team id who won the match as per the win details.

/*
select * from ipl_match;
select * from ipl_team;

SELECT CASE WHEN MATCH_WINNER = 2 THEN TEAM_ID2 ELSE TEAM_ID1 END as winner_team_id FROM ipl_match as IM; 

*/
##final##
select innerquery.TEAM_ID1,(select team_name from ipl_team it where innerquery.TEAM_ID1=it.team_id) team_name_1 ,
innerquery.TEAM_ID2,(select team_name from ipl_team it where innerquery.TEAM_ID2=it.team_id) team_name_2 ,
Innerquery.winner_team_id as winner_team_id , team_name as winner_team_name from
(SELECT TEAM_ID1,TEAM_ID2, case WHEN MATCH_WINNER = 2 THEN TEAM_ID2 
ELSE TEAM_ID1 END as winner_team_id FROM ipl_match) as Innerquery
join ipl_team as itm on Innerquery.winner_team_id = itm.TEAM_ID;


#6.	Display total matches played, total matches won and total matches lost by team along with its team name.

#select * from ipl_team_standings;

select its.team_id, team_name, sum(MATCHES_PLAYED) as total_match_played , sum(MATCHES_WON) as total_match_won,
sum(MATCHES_LOST) as matches_lost, no_result, case when NO_RESULT = 1 then "No_Result"
else "Result Found for all matches"
end as Result_pending
 from ipl_team_standings as its
join ipl_team itm on its.TEAM_ID= itm.team_id group by its.team_id order by NO_RESULT desc;


#7.	Display the bowlers for Mumbai Indians team.

select  itm.team_id, team_name, itp.player_id, player_name, player_role from ipl_team_players as itp
join ipl_team as itm on itp.TEAM_ID=itp.TEAM_ID
join ipl_player as ip on itp.PLAYER_ID = ip.PLAYER_ID
where (PLAYER_ROLE = 'bowler' and team_name like 'Mum%') order by itp.PLAYER_ID;


/* select * from ipl_team;
select * from ipl_team_players;
select * from ipl_player;

select player_id, team_id, player_role from ipl_team_players 
where PLAYER_ROLE = 'bowler' and TEAM_ID = 5; */



/*  8.	How many all-rounders are there in each team, Display the teams with more than 4 
all-rounder in descending order. */

select itp.team_id, team_name, player_role ,count(PLAYER_ROLE) as "total all-rounder"
from ipl_team_players as itp 
join ipl_team AS itm
on itp.TEAM_ID=itm.TEAM_ID
where PLAYER_ROLE like '%roun%' group by team_id having count(PLAYER_ROLE) > 4 order by 4 desc;



