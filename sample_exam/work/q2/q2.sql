-- COMP3311 20T3 Final Exam
-- Q2: view of amazing goal scorers

-- ... helpers go here ...
-- names of all players who have scored MORE THAN ONE goal rated amazing
create or replace view Q2(player,ngoals)
as
select p.name, count(g.id) as ngoals 
from goals g
join players p 
on p.id = g.scoredby 
where g.rating = 'amazing'
group by p.name
having count(g.id) > 1
order by ngoals
;

