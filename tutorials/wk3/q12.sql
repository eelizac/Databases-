-- Tutorial Week 3 
-- Question 12 


create table team {
    name varchar(100), 
    captain varchar(100), 
    primary key (name) 
}; 

create table player {
    name varchar(100), 
    primary key (name)
}; 

create table fan {
    name varchar(100), 
    primary key (name)   
}; 

create table team_colours { -- for multi valued attributes, create a new table 
    team_name text, 
    colour varchar(100), 
    primary key (team_name, colour)
    foreign key team_name references team(name) 
}; 

create table fav_colours { -- for multi valued attributes, create a new table 
    fan_name text, 
    colour varchar(100), 
    primary key (fan_name, colour)
    foreign key fan_name references fan(name) 
}; 

create table fav_team { 
    team_name text,
    fan_name text, 
    primary key (fan_name, team_name),
    foreign key fan_name references fan(name) ,
    foreign key team_name references team(name) 
}; 

create table fav_player { 
    player_name text,
    fan_name text, 
    primary key (fan_name, player_name),
    foreign key fan_name references fan(name) ,
    foreign key team_name references player(name) 
}