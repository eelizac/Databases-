-- Question 2 
-- spread(spread) = s p r e a d 
create or replace 
    function spread(phrase text) returns text 
as 
$$
begin 
declare 
    result text; 
    length integer; 
    i      integer; 
begin 
    i := 1; 
    length := length(phrase); 
    while (i <= length) 
    loop 
        result := result || substr(phrase, i, 1) || ' '; 
        i := i + 1; 
    end loop; 

    return result; 
end; 
$$ language plpgsql