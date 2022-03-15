-- COMP3311 21T3 Assignment 1
-- z5312689 
-- last edited 14/10/21 
-- Fill in the gaps ("...") below with your code
-- You can add any auxiliary views/function that you like
-- The code in this file MUST load into a database in one pass
-- It will be tested as follows:
-- createdb test; psql test -f ass1.dump; psql test -f ass1.sql
-- Make sure it can load without errorunder these conditions


-- Q1: oldest brewery
create or replace view Q1(brewery)
as
select	name 
from 	breweries 
where 	founded = (select min(founded) from breweries)
;

-- SHOWS BEERS X BREWERY 
-- helper function Q2 
create or replace view Beers_Brewery(beer, beers_id, brewery, brewery_id)
as 
select 	beers.name as beer,beers.id as beers_id,  
		breweries.name as brewery, breweries.id as brewery_id 
from 	brewed_by 
join 	beers
on 		beers.id = brewed_by.beer
join	breweries 
on 		breweries.id = brewed_by.brewery
;
-- Q2: collaboration beers
-- beers have registered more than one brewer 
create or replace view Q2(beer)
as
select		beer 
from		(select beer, beers_id, count(beers_id) as count 
			from Beers_Brewery 
			group by beer, beers_id) a 
where not	count = 1
;

-- Q3: worst beer
create or replace view Q3(worst)
as
select	name 
from	beers 
where	rating = (select min(rating) from beers); 
;

-- Q4: too strong beer -- RE DO THIS WITH ACTUAL MAX_ABV

create or replace view Q4(beer,abv,style,max_abv)
as
select	* 
from	(select beers.name as beer, beers.abv, styles.name as style, styles.max_abv 
		from styles 
		join beers on 
		styles.id = beers.style) a
where	abv > max_abv
;


-- Q5 helper 
create or replace view Style_count(name, count_style) 
as 
select		styles.name, count(beers.style) as count_style 
from		beers
join		styles 
on			beers.style=styles.id
group by 	styles.name
; 

-- Q5: most common style

create or replace view Q5(style)
as
select 	name 
from 	Style_count
where 	count_style = (select max(count_style) from style_count); 
;

-- Q6: duplicated style names

create or replace view Q6(style1,style2)
as
select 	a.name, b.name from styles a 
join 	styles b 
on 		lower(a.name) = lower(b.name)
and 	a.name <> b.name
and 	a.name < b.name 
;

-- Q7: breweries that make no beers

create or replace view Q7(brewery)
as
select 	name 
from 	breweries 
except
select 	brewery 
from 	Beers_Brewery
;


-- Q8 - healthy 
create or replace view city_breweries (city, country, count)
as 
select	distinct locations.metro as city, locations.country, 
		count(breweries.id) over (partition by locations.metro) as count
from 	locations join breweries 
on 		locations.id = breweries.located_in
where 	locations.metro is not null
;


-- Q8: city with the most breweries
create or replace view Q8(city,country)
as
select 	city, country 
from 	city_breweries 
where 	count = (select max(count) from city_breweries); 
;

-- Q9: breweries that make more than 5 styles

create or replace view Q9(brewery,nstyles)
as
select 		brewery, count(brewery) as nstyles
from		(select distinct b.brewery, b.brewery_id, a.style
			from Beers_Brewery b 
    		join beers a 
    		on b.beers_id = a.id) t 
group by 	brewery
having 		count(style) > 5 
order by 	brewery
;

-- Q10: beers of a certain style

-- make a view 
create or replace view collaboration_beer(beers_id, beer, brewery)
as
select	 	beers_id, beer, STRING_AGG(brewery, ' + ') AS brewery 
from 		(select 	a.beers_id, a.beer, b.brewery 
			from		(select beer, beers_id, count(beers_id) as count 
						from Beers_Brewery 
						group by beer, beers_id) a 
			join		Beers_Brewery b 
			on 			a.beers_id = b.beers_id 
			where not	a.count = 1
			order by 	beer, brewery) c
group by 	beer, beers_id
union 
select 		d.beers_id, d.beer, e.brewery 
from		(select 	beer, beers_id, count(beers_id) as count 
			from 		Beers_Brewery 
			group by	beer, beers_id) d
join 		Beers_Brewery e 
on 			d.beers_id = e.beers_id 
where		d.count = 1
order by	beer, brewery 
;

-- have a BeerInfo VIEW that returs tuples of this type - in which the type would be automatically defined 
create or replace view Beer_info_view(beer, brewery, style, year, abv)
as
select	beers.name as beer, collaboration_beer.brewery, styles.name as style, 
		beers.brewed as year, beers.abv as abv from beers
join 	styles 
on 		beers.style = styles.id 
join 	collaboration_beer 
on 		beers.id = collaboration_beer.beers_id
;

create type BeerInfo as (
	beer text, 
	brewery text, 
	style text, 
	year YearValue, 
	abv ABVvalue
)
; 

create or replace function
q10(_style text) returns setof BeerInfo
as $$
declare 
	_beer BeerInfo;
begin 
	for _beer in (select * from Beer_info_view where style = _style)
	loop 
		return next _beer; 
	end loop; 
end; 
$$
language plpgsql;

-- Q11: beers with names matching a pattern
-- take a string as argument and finds all beers that contain that string in their name 
create or replace function
	Q11(partial_name text) returns setof text
as $$
declare 
	_beer record; 
	info text; 
begin 
	for _beer in (select * from Beer_info_view where lower(beer) like '%' || partial_name || '%')
	loop 
		info := '"'|| _beer.beer || '", ' ; 
		info := info  || _beer.brewery || ', ' ; 
		info := info || _beer.style || ', '; 
		info := info  || _beer.abv || '% ABV'; 
		return next info; 
	end loop; 
end; 
$$
language plpgsql;

-- Q12: breweries and the beers they make
-- Gets information about all breweries that contain that string in their name 

-- Helper view 
create or replace view Location_Breweries(name, founded, town, metro, region, country)
as
select	breweries.name as name, breweries.founded, locations.town, 
		locations.metro, locations.region, locations.country
from 	breweries 
join 	locations 
on 		breweries.located_in = locations.id
;



create or replace function
	Q12(partial_name text) returns setof text
as $$
declare 
	_brewery record; info text; _beer BeerInfo; 
    num_beers integer; num_breweries integer; 
begin 
	for _brewery in (select * from Location_Breweries where lower(name) like '%' || partial_name || '%' order by name)
	loop 
		info := _brewery.name || ', founded ' || _brewery.founded; 
		return next info;

		info := 'located in '; 
		-- locations 
		if (_brewery.town is not null and _brewery.metro is not null) then 
			info := info || _brewery.town ; 
		elsif (_brewery.town is not null ) then 
			info := info || _brewery.town; 
		elsif (_brewery.metro is not null) then 
			info := info || _brewery.metro; 
		end if; 

		if _brewery.region is not null then 
			info := info || ', ' || _brewery.region; 
		end if;
		info := info || ', ' || _brewery.country; 
	 	return next info; 

        select count(*) into num_breweries from Location_Breweries where lower(name) like '%' || partial_name || '%' ; 
        -- BEERS
        select count(*) into num_beers from Beer_info_view where lower(brewery) like '%' || partial_name || '%' ; 

        if (num_beers = 0 and num_breweries > 0) then 
            info := '  No known beers'; 
            return next info; 
        else 
            for _beer in (select * from Beer_info_view where brewery like '%' ||  _brewery.name || '%' order by year, beer)
            loop
                info := '  "' || _beer.beer || '", ' || _beer.style || ', ' || _beer.year || ', ' || _beer.abv || '% ABV'; 
                return next info; 
            end loop; 
        end if; 
    end loop; 
end; 
$$
language plpgsql;