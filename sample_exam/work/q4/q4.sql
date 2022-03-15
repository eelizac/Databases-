-- COMP3311 20T3 Final Exam
-- Q4: function that takes two team names and
--     returns #matches they've played against each other
-- return 0 if never played each other; if not a team them NULL
-- ... helper views and/or functions (if any) go here ...

-- returns all the ids of matches involving that country 
create or replace function 
	MatchesFor(text) returns setof integer 
as $$
select	m.id
from	matches m 
		join involves i on (m.id = i.match)
		join teams t on (t.id = i.team)
where	t.country = $1 
$$ language sql; 

create or replace function
	Q4(_team1 text, _team2 text) returns integer
as $$
declare
	_count integer; -- number of matches 
begin 
	perform * from teams where country = _team1; 
	if (not found) then return NULL; end if; 
	perform * from teams where country = _team2; 
	if (not found) then return NULL; end if; 

	select count(*) into _count
	from	((select * from MatchesFor(_team1)) 
			 intersect 
			 (select * from MatchesFor(_team2))
			) as X ;
	return _count; 
end; 
$$ 
language plpgsql
;
