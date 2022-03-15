-- COMP3311 21T3 Exam Q2
-- Number of unsold properties of each type in each suburb
-- Ordered by type, then suburb

create or replace view q2(suburb, ptype, nprops)
as
select s.name as suburb, p.ptype, count(*) as nprops 
from properties p 
join streets st 
on p.street = st.id 
join suburbs s 
on st.suburb = s.id 
where sold_date IS NULL
group by s.name, p.ptype 
order by p.ptype, s.name, count(*)

;
