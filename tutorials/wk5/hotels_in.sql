-- select hotels in (the rocks) - etc. 
-- Question 8 
create or replace 
    function license() return setof Bars 
as 
$$
declare 
    row Bar; 
    numbers integer; 
begin 
    for row in (select * from Bars where license::text ~ '1.*')
    loop 
        return next row; 
    end loop; 
end; 



create or replace 
    function hotelsIn(location text) return text 
as 
$$
declare 
    hotels text; 
    tuple record; 
    matches integer;  
begin 
    select count(*) into matches from Bars 
    where addr ~* location; 

    if matches == 0 then 
        hotels := 'There are no hotels in' || location; 
        return hotels; 
    else 
        hotels := 'Hotels in' || location || ':'; 
        for tuple in (select * from Bars where addr ~* location)
        loop 
            hotels := hotels || ' ' || tuple.name; 
        end loop; 
    end if; 
    return hotels; 
end; 
