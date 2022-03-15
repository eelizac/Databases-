-- q8.sql 

-- ER MAPPING 
CREATE TABLE Employee (
    id int serial, 
    name text not null, 
    position text 
    primary key(id)
);

CREATE TABLE PartTime (
    emp_id int primary key, 
    fraction float check(0.0 < fraction and fraction < 1.0), 
    foreign key (emp_id) references Employee(id)
);

CREATE TABLE Casual (
    emp_id int primary key, 
    foreign key (emp_id) references Employee(id)
);

-- how do i then 
CREATE TABLE worked (
    date date not null , 
    id int, -- do i need
    starting time not null, 
    ending time not null , 
    foreign key (id) references Casual(id), 
    primary key (date) 
    constraint timing check (starting < ending) -- do not forget checks 
);

-- As this schema does not capture the disjoint that Employees can only be partime or casual, it is not preserved. 
-- We cannot enforce total participation constraint 
-- We cannot enforce the disjoint subclasses constraint 


-- SINGLE TABLE MAPPING 
create table Employee (
    id int primary key, 
    name text, 
    position text, 
    etype text not null check (etype in ('part-time', 'casual')), -- can encfroe the disjoint subcalss 
    fraction float check (0.0 < fraction and fraction < 1.0),
    primary key (id)
    constraint CheckValidTypeData check ((etype = 'part-time' and fraction is not null) or (etype = 'casual' and fraction is null))
); 

create table HoursWorked (
    id int primary key
    Ondate date primary key, 
    starting time, 
    ending time, 
    foreign key id references Employee(id)
    constraint timing check (starting < ending)
); 

-- Checkvalidtype data allows for disjoint 
-- not null requirements allows for total participation 