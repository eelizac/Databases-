-- COMP3311 21T3 Exam Q4
-- Return address for a property, given its ID
-- Format: [UnitNum/]StreetNum StreetName StreetType, Suburb Postode
-- If property ID is not in the database, return 'No such property'

create or replace view address_apartment as
select p.id, p.unit_no, p.street_no, s.name as street, s.stype, su.name as suburb, su.postcode 
from properties p 
join streets s
on p.street = s.id
join suburbs su 
on s.suburb = su.id
where p.ptype = 'Apartment'
; 

create or replace view address_house as
select p.id, p.street_no, s.name as street, s.stype, su.name as suburb, su.postcode 
from properties p 
join streets s
on p.street = s.id
join suburbs su 
on s.suburb = su.id
where p.ptype = 'House' or p.ptype = 'Townhouse'
; 

create or replace function
    get_type(int) returns text
as $$
select ptype 
from properties 
where id = $1
;
$$ language sql;

create or replace function address(propID integer) returns text
as
$$
declare
	ptype text; 
	_address text; 
	x record; 
begin
	ptype = get_type(propID); 
	if ptype is null then
		return 'No such property';
	end if; 

	if ptype = 'Apartment' then 
		for x in (select * from address_apartment where id = propID)
		loop 
			_address := x.unit_no || '/' || x.street_no || ' ' || x.street || ' ' || x.stype || ', ' || x.suburb || ' ' || x.postcode ; 
		end loop; 
	end if; 

	if ptype = 'House' or ptype = 'Townhouse' then 
		for x in (select * from address_house where id = propID)
		loop 
			_address := x.street_no || ' ' || x.street || ' ' || x.stype || ', ' || x.suburb || ' ' || x.postcode ; 
		end loop; 
	end if; 

	return _address; 
end;
$$ language plpgsql;
