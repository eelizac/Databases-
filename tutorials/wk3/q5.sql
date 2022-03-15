-- Tutorial Week 3 
-- Question 5 

create table R {
    id serial, -- ensures database remains consistent  
    -- unique is built into serial // specific to each table 
    name varchar(100),  -- typical 
    address varchar(100),
    d_o_b date, -- date is a datatype 
    primary key (id)
}; -- need the ; 


create table S {
    name varchar(100), 
    address varchar(100),
    d_o_b date, 
    primary key (name, address), -- only way to define a composite key 
    foreign key name references R(name),
    foreign key address references R(address)
}
