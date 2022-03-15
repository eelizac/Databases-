create or replace function
	Q4(_team1 text, _team2 text) returns integer
as $$
declare
	_count integer := 0; -- number of matches 
	_match record;
	_country record;
begin 
	for _match in (select match from team_matches where country = _team1)
	loop
		for _country in (select country from team_matches where match = _match)
		loop 
			if (_country = _team2) then 
				_count := _count + 1;
			end if; 
		end loop; 
	end loop;
	return _count; 
end; 
$$ 
language plpgsql
;
