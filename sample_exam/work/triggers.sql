-- q9 sql


Courses(id,subject,term,homepage)
CourseEnrolments(student,course,mark,grade,stueval)


create trigger AddCourseEnrolmentTrigger
after insert on CourseEnrolments
execute procedure fixCoursesOnAddCourseEnrolment();

create trigger DropCourseEnrolmentTrigger
after delete on CourseEnrolments
execute procedure fixCoursesOnDropCourseEnrolment();

create trigger ModCourseEnrolmentTrigger
after update on CourseEnrolments
execute procedure fixCoursesOnModCourseEnrolment();



-- Courses(id,subject,term,homepage,nS,nE,avgEval)
create function fixCoursesOnAddCourseEnrolment() returns trigger as $$
declare 
    _nS integer; _nE integer; _sum integer; _avg float; 
begin 
    select nS, nE, avgEval into _nS, _nE, _avg 
    from Courses where id = new.course -- new for insert 
    -- ad another student 
    _nS = _nS + 1; 
    if (new.stueval is not null) then 
        _nE := _nE + 1; -- the number of student who gave an evaluation increases 
        if (_nS <= 10 or (3*_nE) <= _nS) then  -- invalid 
            _avg := null; 
        else
            select sum(stueval) into _sum
            from CourseEnrolments where course=new.course; 
            _sum := _sum + new.stueval; 
            _avg := _sum::float /_nE; 
        end if; 
    end if; 
    update Courses set nS = _nS, nE = _nE, avgEval = _avg -- insert back into 
    where id = new.course; 
    return new; 
$$ language plpgsql;



create function fixCoursesOnDropCourseEnrolment() returns trigger as $$
declare 
    _nS integer; _nE integer; _sum integer; _avg float; 
begin 
    select nS, nE, avgEval into _nS, _nE, _avg 
    from Courses where id = old.course -- new for insert 
    -- ad another student 
    _nS = _nS - 1; 
    if (old.stueval is not null) then 
        _nE := _nE - 1; -- the number of student who gave an evaluation increases 
        if (_nS <= 10 or (3*_nE) <= _nS) then  -- invalid 
            _avg := null; 
        else
            select sum(stueval) into _sum
            from CourseEnrolments where course=old.course and student <> old.student; 
            _avg := _sum::float /_nE; 
        end if; 
    end if; 
    update Courses set nS = _nS, nE = _nE, avgEval = _avg -- insert back into 
    where id = old.course; 
    return old; 
$$ language plpgsql;



create function fixCoursesOnModCourseEnrolment() returns trigger as $$
declare 
    _newEval integer; _oldEval integer; 
    _nS integer; _nE integer; _sum integer; _avg float; 
begin 
    select nS, nE, avgEval into _nS, _nE, _avg 
    from Courses where id = old.course 
    if (old.stueval is not null and new.stueval is not null) then 
        _nE := _nE + 1; -- the number of student who gave an evaluation increases 
    end if; 

    _oldEval := coalesce(old.stueval,0); 
    _newEval := coalesce(new.stueval, );

    if (_oldEval <> _newEval) then
        select sum(stueval) into _sum
        from CourseEnrolments where course = old.course; 
        _avg := (_sum - _oldEval + _newEval)::float / _nE; 
    end if;

    update Courses set nS = _nS, nE = _nE, avgEval = _avg
    where id = old.course; 
    return new; 
end;   
$$ language plpgsql;