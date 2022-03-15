-- COMP3311 20T3 Final Exam
-- Q1: view of teams and #matches

-- ... helper views (if any) go here ...
-- Write a SQL view that gives the country name for each team and the number of matches it has played 
create or replace view Q1(team,nmatches)
as
select country as team, count(match) as nmatches from involves i 
join teams t
on t.id = i.team
group by country
order by country
;

