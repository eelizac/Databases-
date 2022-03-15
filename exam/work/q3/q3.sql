-- COMP3311 21T3 Exam Q3
-- Unsold house(s) with the lowest listed price
-- Ordered by property ID

create or replace view q3(id,price,street,suburb)
as
select p.id, p.list_price as price, concat(p.street_no, ' ', s.name,' ', s.stype) as street, su.name as suburb
from properties p 
join streets s
on p.street = s.id
join suburbs su 
on s.suburb = su.id
where sold_date is null
and ptype = 'House'
and p.list_price = (select min(list_price) from properties where sold_date is null and ptype = 'House')
order by p.id
;
