-- COMP3311 20T3 Final Exam Q6
-- Put any helper views or PLpgSQL functions here
-- You can leave it empty, but you must submit it

-- a list of match reports for team 
create or replace view match_goals_info as 
select m.id, country, city, playedon, count(g.id) as goal_count
from matches m 
full outer join involves i 
on m.id = i.match
full outer join teams t 
on t.id = i.team 
full outer join goals g
on g.scoredin = m.id
full outer join players p 
on p.id = g.scoredby 
and p.memberof = t.id
group by country, city, playedon, m.id
; 


select * from 
teams t 
join goals g
on g.scoredin = m.id
full outer join players p 
on p.id = g.scoredby 
and p.memberof = t.id
group by country, city, playedon, m.id
; 





create or replace view versus_goals_info as 
select a.id, a.country as a_country, b.country as b_country, a.city, a.playedon, a.goal_count as a_goals, b.goal_count as b_goals from match_goals_info a
join match_goals_info b 
on a.id = b.id 
and a.city = b.city 
and a.playedon = b.playedon
where a.country <> b.country
order by id 
;