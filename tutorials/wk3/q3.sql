-- Week 3 Tutorial 
-- Question 3 
-- parent entity with overlap 3 sub entities 

CREATE TABLE P {
    id int,
    a text,
    primary key (id) --> must be a unique identifier between each dataset and not null 
}; 

CREATE TABLE R {
    id int, 
    b int,
    foreign key (id) references P(id), -- reference to table P 
    primary key (id) -- ALSO is a primary key! all tables need a primary key 
}; 

CREATE TABLE S {
    id int ,
    c int,
    foreign key (id) references P(id),
    primary key (id) 
}; 

CREATE TABLE T {
    id int ,
    d int,
    foreign key (id) references P(id),
    primary key (id) 
}