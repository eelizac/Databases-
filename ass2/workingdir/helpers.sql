-- COMP3311 21T3 Ass2 ... extra database definitions
-- add any views or functions you need into this file
-- note: it must load without error into a freshly created mymyunsw database
-- you must submit this even if you add nothing to it

-- helper for trans 
create or replace view transcript_view as 
select  subjects.code as code, terms.code as term, subjects.name as name, 
        ce.mark, ce.grade, subjects.uoc, ce.student 
from    courses join terms 
on      courses.term = terms.id 
join    subjects 
on      subjects.id = courses.subject 
join    course_enrolments ce 
on      ce.course = courses.id  
order by terms.id, terms.starting, subjects.code
; 

create or replace function
transcript(_zid integer) returns setof TranscriptRecord
as $$
declare 
	_course TranscriptRecord; 
info text; 
begin 
	for _course in (select code, term, name, mark, grade, uoc from transcript_view where student = _zid)
	loop 
		return next _course; 
	end loop; 
end; 
$$
language plpgsql;


-- helper for rules 
create or replace view program_school_view as 
select	p.id, p.name, p.uoc, p.duration, o.longname as school
from	orgunits o
join	programs p
on		o.id = p.offeredby
;

create or replace view rules_program_view as 
select	* 
from 	program_rules 
join 	rules 
on 		rules.id = program_rules.rule
; 

create or replace view stream_rules_view as 
select 	* 
from 	stream_rules
join 	rules
on 		rules.id = stream_rules.rule
; 


create or replace view stream_subject_view as 
select 	id, code, name from subjects 
union 
select 	id, code, name from streams
; 


create or replace view streams_info_view as 
select	streams.code, streams.name, stream_rules.stream, orgunits.longname as school,
		rules.name as rules, rules.type, min_req, max_req, a.definition  
from	stream_rules
join	streams
on		streams.id = stream_rules.stream 
join 	rules 
on 		stream_rules.rule = rules.id 
join 	academic_object_groups a 
on 		a.id = rules.ao_group 
join 	orgunits 
on 		orgunits.id = streams.offeredby 
;

create or replace view student_program_stream_view 
as 
select	peo.id, peo.family, peo.given, p.code, p.name as program_name, s.code as stream_code, s.name as stream_name
from	program_enrolments pe 
join	programs p 
on 		p.id = pe.program 
join	stream_enrolments se 
on 		pe.id = se.partof 
join	people peo 
on 		peo.id = pe.student 
join	streams s 
on		s.id = se.stream
;

create or replace view program_rules_definition as 
select	program, p.name, uoc, p.offeredby, career, rules.name as rule, rules.type, min_req, max_req, ao.definition, ao.type as ao_type, ao.defby
from	program_rules pr 
join	programs p 
on		p.id = pr.program
join	rules 
on 		rules.id = pr.rule
join 	academic_object_groups ao
on 		ao.id = rules.ao_group
; 