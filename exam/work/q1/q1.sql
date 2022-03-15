-- COMP3311 21T3 Exam Q1
-- Properties most recently sold; date, price and type of each
-- Ordered by price, then property ID if prices are equal

create or replace view q1(date, price, type)
as
select p.sold_date as date,p.sold_price as price, p.ptype as type
from properties p
where sold_price is not null and sold_date = (select max(sold_date) from properties)
order by p.sold_price 
;
