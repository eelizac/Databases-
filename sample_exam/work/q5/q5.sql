-- COMP3311 20T3 Final Exam
-- Q5: show "cards" awarded against a given team

-- ... helper views and/or functions go here ...

drop function if exists q5(text);
drop type if exists RedYellow;

create type RedYellow as (nreds integer, nyellows integer);

create or replace view team_cards (country, cardtype, count)
as
select t.country , c.cardtype, count(cardtype) as count
from players p
join cards c 
on p.id = c.givento 
right outer join teams t 
on t.id = p.memberof
group by t.country, c.cardtype
order by t.country, c.cardtype
;


create or replace function
	Q5(_team text) returns RedYellow
as $$
declare 
	info RedYellow; 
begin 
	-- if it is not a team 
	if (select id from teams where country = _team) IS NULL then 
		info.nyellows := NULL;
		info.nreds := NULL;
	else  
		info.nyellows := coalesce((select count from team_cards where country = _team and cardtype ='yellow'), 0);
		info.nreds := coalesce((select count from team_cards where country = _team and cardtype ='red'), 0);
	end if; 
	return info;
	
end; 
$$ language plpgsql
;
