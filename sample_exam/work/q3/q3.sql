-- COMP3311 20T3 Final Exam
-- Q3: team(s) with most players who have never scored a goal

... helpers go here ...

create or replace view player_ngoals_0(team,nplayers)
as
select team, count(name) as nplayers 
from (
    select t.country as team, p.name, count(g.id) as ngoals 
    from goals g
    right outer join players p 
    on p.id = g.scoredby 
    join teams t 
    on t.id = p.memberof
    group by p.name, t.country
    order by count(g.id)
) a
where ngoals = 0 
group by team 
;

create or replace view Q3(team,nplayers)
as
select * from player_ngoals_0
where nplayers = (select max(nplayers) from player_ngoals_0)
;

