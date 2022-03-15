select brewery, count(brewery)
from (
    select distinct b.brewery, b.brewery_id, a.style
    from Beers_Brewery b 
    join beers a 
    on b.beers_id = a.id
)t 
group by brewery
having count(style) > 5; 