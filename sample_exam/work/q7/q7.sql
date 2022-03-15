-- COMP3311 20T3 Final Exam Q7
-- Put any helper views or PLpgSQL functions here
-- You can leave it empty, but you must submit it

create or replace view goal_player_count as 
select p.name, m.city, m.playedon, count(g.id) as goal_count 
from players p 
full outer join goals g 
on p.id = g.scoredby 
full outer join matches m
on m.id = g.scoredin
join teams t 
on t.id 
group by m.city, m.playedon, p.name
order by m.playedon 
;

