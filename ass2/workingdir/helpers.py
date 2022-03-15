# COMP3311 21T3 Ass2 ... Python helper functions
# add here any functions to share between Python scripts 
# you must submit this even if you add nothing
import re 

def getProgram(db,code):
  cur = db.cursor()
  cur.execute("select * from Programs where code = %s",[code])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

def getStream(db,code):
  cur = db.cursor()
  cur.execute("select * from Streams where code = %s",[code])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

def list_diff (l1, l2): 
  """
  Returns the difference between 2 lists 
  """
  diff = []
  for x in l1: 
    if x not in l2: 
      diff.append(x)

  return diff

def split_altern(alternates): 
  """
  Splits the format of alternative courses e.g. {MATH11131;MATH1141} and return a list 
  """
  # return array with 2 alternate courses 
  remove_last = alternates[:-1] # remove hte last }
  remove_first = remove_last[1:]
  altern = remove_first.split(";")
  return altern


def in_list(x, course_list, code): 
  """
  Returns if a x is in a list of dictionaries 
  """
  count = 0 
  if code: 
    for course in course_list: 
      if course["code"] == x: 
        return 1
  else: 
    length = len(x)
    for course in course_list:
      if course["rule"][:length] == x: 
        count = count + 1 

  return count 

def num_gen_eds(course_list):
  """
  Returns the number of general elective courses in list of dict 
  """
  count = 0 
  for course in course_list: 
    if course["code"][:3] == "GEN": 
      count = count + 1 
  return count 

def remove_from_list(course, course_list): 
  """
  Removes a course in a list of dictionaries 
  """
  for x in course_list: 
    if x["code"] == course: 
      course_list.remove(x)
      break; 

def remove_from_list_rule(rule, course_list): 
  """
  Removes a dictionary from a list of dictionaries where rule is found 
  """
  lapp = []
  for x in course_list: 
    if x["rule"] == rule:
      course_list.remove(x)
      lapp.append(x)

  return [course_list, lapp]
#completed_uoc = course_count(completed_courses, stream_rule[0])*6 
def course_count(completed_courses, rule):
  """
  Returns the number of courses that have been completed in that rule 
  """
  count = 0
  for course in completed_courses: 
    if course["rule"] == rule: 
      count = count + 1
  return count 

def getStudent(db,zid):
  cur = db.cursor()
  qry = """
  select p.*, c.name
  from   People p
         join Students s on s.id = p.id
         join Countries c on p.origin = c.id
  where  p.id = %s
  """
  cur.execute(qry,[zid])
  info = cur.fetchone()
  cur.close()
  if not info:
    return None
  else:
    return info

def uoc_valid(grade):
  """
  Returns if a grade is valid to be calcualted in total UOC 
  """ 
  #returns true if the grade is valid for UOC 
  if grade in ['HD', 'DN', 'CR', 'PS','XE', 'T', 'SY', 'EC', 'NC', 'A', 'B', 'C', 
              'D', 'A+', 'B+', 'C+', 'D+', 'A-', 'B-', 'C-', 'D-']: 
    return 1
  else: 
    return 0 

def print_transcript(results):
  """
  Print list of formatted transcript - helper function for trans 
  """
  sum_mark_uoc = 0
  total_uoc_mark = 0 
  total_uoc = 0
  for result in results: 
  
    mark = " -" if result[3] == None else result[3]
    if result[4] in ['AF', 'FL', 'UF']: 
      print(f"{result[0]} {result[1]} {result[2]:<32s}{mark:>3} {result[4]:2s}   fail")
    elif result[4] in ['AS','AW','PW','RD','NF','LE','PE','WD','WJ']: 
      print(f"{result[0]} {result[1]} {result[2]:<32s}{mark:>3} {result[4]:2s}")
    else: 
      print(f"{result[0]} {result[1]} {result[2]:<32s}{mark:>3} {result[4]:2s}  {result[5]:2d}uoc")

    # for WAM calculation 
    if result[4] in ['HD', 'DN', 'CR', 'PS', 'AF', 'FL', 'UF']:  
      if  result[3] != None:
        sum_mark_uoc = sum_mark_uoc + (result[3]*result[5])
      total_uoc_mark = total_uoc_mark + result[5]
    
    # for UOC calculation 
    if uoc_valid(result[4]): 
      total_uoc = total_uoc + result[5]

  wam = sum_mark_uoc / total_uoc_mark
  print(f"UOC = {total_uoc}, WAM = {wam:.1f}")
      

def print_courses(cur, course_list): 
  """
  From a list of courses, print in formatted way
  """
  query_courses = "select name from stream_subject_view where code = %s"
  for course in course_list: 
    if course[0] == "{": 
      altern = split_altern(course)
      for x in altern: 
        cur.execute(query_courses, [x])
        name = cur.fetchone()
        if name == None: 
          print(f"- {x} ???") if x == altern[0] else print(f"  or {x} ???")
        else: 
          print(f"- {x} {name[0]}") if x == altern[0] else print(f"  or {x} {name[0]}")
    else: 
      cur.execute(query_courses, [course])
      name = cur.fetchone()
      print(f"- {course} ???") if name == None else print(f"- {course} {name[0]}")


def print_student_info(cur, zid, progCode, strmCode): 
  """
  Prints the initial student information helper function for prog 
  """
  query_student = "select * from student_program_stream_view where id = %s"
  query_student1 = "select * from student_program_stream_view where id = %s and code = %s and stream_code = %s"
  query_student2A = "select id, family, given from people where id = %s"
  query_student2B = "select id, name from programs where id = %s"
  query_student2C = "select code, name from streams where code = %s"

  if progCode != None and strmCode != None: 
    cur.execute(query_student1, [zid, progCode, strmCode])
    student_info = cur.fetchone() 
    if student_info == None: # do it manually
      cur.execute(query_student2A, [zid])
      student = cur.fetchone()
      print(f"{student[0]} {student[1]}, {student[2]}")

      cur.execute(query_student2B, [progCode])
      prog = cur.fetchone()
      print(f"  {prog[0]} {prog[1]}")

      cur.execute(query_student2C, [strmCode])
      strm = cur.fetchone() 
      print(f"  {strm[0]} {strm[1]}")     
    else: 
      print(f"{student_info[0]} {student_info[1]}, {student_info[2]}")
      print(f"  {student_info[3]} {student_info[4]}")
      print(f"  {student_info[5]} {student_info[6]}") 

    return progCode, strmCode
  else: 
    cur.execute(query_student, [zid])
    student_info = cur.fetchone() # get most recent 

    print(f"{student_info[0]} {student_info[1]}, {student_info[2]}")
    print(f"  {student_info[3]} {student_info[4]}")
    print(f"  {student_info[5]} {student_info[6]}") 

    return student_info[3], student_info[5]


def print_completed(cur, zid, strmCode, progCode):
  """
  Print a list of completed courses - helper function for prog 
  """ 
  query = "select * from transcript(%s)"
  query_rule = "select rule,type from program_rules_definition where definition like %s and program = %s"
  query_rule1 = "select rules,min_req,max_req from streams_info_view where definition like %s and code = %s"
  total_uoc = 0
  
  cur.execute(query,[zid])
  results = cur.fetchall()
  print("\nCompleted:")
  completed_courses = [] # a list of dictionaries 
  failed_courses = []
  for result in results: 
    valid_uoc = 1
    pattern = "%" + result[0] +  "%"
    if result[4] == "FL": 
      print(f"{result[0]} {result[1]} {result[2]:<32s}{result[3]:>3} {result[4]:2s}   fail does not count")
      failed_courses.append(result[0])

    else: 
      if result[3] == None: 
        grade = " -"
        if result[4] == None: 
          mark = " -"
          print(f"{result[0]} {result[1]} {result[2]:<32s}  - {mark:2s}        does not count")
          valid_uoc  = 0
          continue 
      else:
        grade = result[3]

      cur.execute(query_rule,[pattern, progCode])
      rule = cur.fetchone()

      if rule == None: 
        updated_pattern = "%" + result[0][:5] +  "###%" # do hash ones 
        cur.execute(query_rule1, [updated_pattern, progCode])
        rule = cur.fetchone()
 
      if rule == None: # still no rule
        cur.execute(query_rule1,[pattern, strmCode])
        stream_rule = cur.fetchone() 
        if stream_rule == None: 
          updated_pattern = "%" + result[0][:5] +  "###%" # do hash ones 
          cur.execute(query_rule1, [updated_pattern, strmCode])
          stream_rule = cur.fetchone()  
        if stream_rule == None: 
          # check if there is a free elective needed before making it invalid 
            cur.execute(query_rule1, ["FREE####", strmCode])
            fe = cur.fetchone()
            if fe == None: 
              print(f"{result[0]} {result[1]} {result[2]:<32s}{grade:>3} {result[4]:2s}   0uoc does not satisfy any rule")
              valid_uoc  = 0
            else: # there is a free elective 
              completed_uoc = course_count(completed_courses, fe[0])*6
              
              if fe[2] != None and fe[2] <= completed_uoc: 
                print(f"{result[0]} {result[1]} {result[2]:<32s}{grade:>3} {result[4]:2s}   0uoc does not satisfy any rule")
                valid_uoc  = 0
              else: 
                # check the amount of 
                print(f"{result[0]} {result[1]} {result[2]:<32s}{grade:>3} {result[4]:2s}  {result[5]:2d}uoc towards Free Electives") 
                completed_courses.append({"code": result[0], "rule":fe[0]})  
         
        else: 
          # Check if rule has been maxed 
          completed_uoc = course_count(completed_courses, stream_rule[0])*6
          if stream_rule[2] != None and stream_rule[2] <= completed_uoc: 
            print(f"{result[0]} {result[1]} {result[2]:<32s}{grade:>3} {result[4]:2s}   0uoc does not satisfy any rule")
            valid_uoc  = 0
          else: 
            print(f"{result[0]} {result[1]} {result[2]:<32s}{grade:>3} {result[4]:2s}  {result[5]:2d}uoc towards {stream_rule[0]}") 
            completed_courses.append({"code": result[0], "rule":stream_rule[0]})     

      else: 
        if rule[1] == "PE": 
          # need to do something 
          cur.execute(query_rule1,[pattern, strmCode])
          stream_rule = cur.fetchone()
          rule = stream_rule[0] + " + " + rule[0]
        else: 
          rule = rule[0]

        print(f"{result[0]} {result[1]} {result[2]:<32s}{grade:>3} {result[4]:2s}  {result[5]:2d}uoc towards {rule}")
        completed_courses.append({"code": result[0], "rule": rule})

    if uoc_valid(result[4]):
      if valid_uoc: 
        total_uoc = total_uoc + result[5]

  print(f"UOC = {total_uoc} so far")
  return completed_courses, failed_courses

def print_remaining_course(cur, course_list, completed_courses, failed_courses, grad_eligible): 
  """
  Print formatting list of courses from a course list if they are eligible. Helper function for print_remaining() 
  """
  query_courses = "select name from stream_subject_view where code = %s"
  for course in course_list:
    cur.execute(query_courses, [course])
    name = cur.fetchone()
    if course[0] == "{": # an alternate one 
      altern = split_altern(course)
      if ((in_list(altern[0], completed_courses, 1) == 0) or (altern[0] in failed_courses)) and ((in_list(altern[1], completed_courses, 1) == 0) or (altern[1] in failed_courses)): 
        for x in altern: 
          cur.execute(query_courses, [x])
          name = cur.fetchone()
          if grad_eligible == 1: 
            print("\nRemaining to complete degree:")
            grad_eligible = 0 
          if name == None: 
            print(f"- {x} ???") if x == altern[0] else print(f"  or {x} ???")
          else: 
            print(f"- {x} {name[0]}") if x == altern[0] else print(f"  or {x} {name[0]}")
    else: 
      if (course in failed_courses) or (in_list(course, completed_courses, 1) == 0):
        # but if failed course must not be in completed 
        if (course in failed_courses) and in_list(course, completed_courses, 1): 
          continue; 
        cur.execute(query_courses, [course])
        name = cur.fetchone()
        if grad_eligible == 1: 
          print("\nRemaining to complete degree:")
          grad_eligible = 0 

        print(f"- {course} ???") if name == None else print(f"- {course} {name[0]}")
    
  return grad_eligible 

def print_remaining(cur, zid, strmCode, progCode, completed_courses, failed_courses):
  """
  Print list of remaining courses - helper function for prog 
  """
  query = "select rules, min_req, max_req, type, definition from streams_info_view where code = %s"
  query_rule = "select rule, type, min_req, max_req, ao_type, definition from program_rules_definition where program = %s"
  electives = []
  general_elective = 0
  grad_eligible = 1
  free_elective = []
  cur.execute(query_rule, [progCode])
  rules = cur.fetchall()
  for rule in rules: 
    if rule[1] == "CC":
      grad_eligible = print_remaining_course(cur, rule[5].split(","), completed_courses, failed_courses, grad_eligible)

    elif rule[1] == "DS": #looking at stream specific courses 
      cur.execute(query,[strmCode])
      results = cur.fetchall() 
      for result in results: 
        if result[3] == "CC": # CORE COURSE 
          grad_eligible = print_remaining_course(cur, result[4].split(","), completed_courses, failed_courses, grad_eligible)
        elif result[3] == "FE": 
          free_elective = [result[0], result[1], result[2]]
        else: #PE 
          if result[2] == None: 
              uoc_remaining = result[1]
          elif result[1] == None: 
            continue 
          else:
            uoc_remaining = result[2] #total amount of UOC to compelte 
          
          uoc_remaining = uoc_remaining - (in_list(result[0], completed_courses, 0)*6)
          string = f"at least {uoc_remaining} UOC courses from {result[0]}" if result[2] == None else  f"between 0 and {uoc_remaining} UOC courses from {result[0]}"

          if uoc_remaining > 0 and (string not in electives):  
            if grad_eligible == 1: 
              print("\nRemaining to complete degree:")
              grad_eligible = 0 
            electives.append(string)
    
    elif rule[1] == "GE":
      general_elective = 1 
      for x in electives: 
        print(x)

      uoc_gened = rule[2] - num_gen_eds(completed_courses)*6

      if uoc_gened > 0: 
        if grad_eligible == 1: 
          print("\nRemaining to complete degree:")
          grad_eligible = 0 
        print(f"{uoc_gened} UOC of General Education")

    else: # PE 
      if rule[2] == rule[3]: 
        uoc_remaining = rule[2]
      elif result[3] == None: 
        uoc_remaining = rule[2]
      else: # result[2] == None or different 
        uoc_remaining = rule[3]

      for course in rule[5].split(","):
        if course[5] == "#": 
          for x in completed_courses:
            if ((x["code"][:5] + "###") == course) and (x["rule"] == rule[0]): 
              uoc_remaining = uoc_remaining - 6
        else: 
          if in_list(course, completed_courses,1):
            uoc_remaining = uoc_remaining - 6

      if uoc_remaining > 0:    
        string = f"{uoc_remaining} UOC from ADK Courses" if rule[0] == "ADK Courses" else f"{uoc_remaining} UOC courses from {rule[0]}"
        electives.append(string)
        if grad_eligible == 1: 
          print("\nRemaining to complete degree:")
          grad_eligible = 0 

  # printing GEs and FEs 
  if general_elective == 0: 
    if grad_eligible == 1: 
      print("\nRemaining to complete degree:")
      grad_eligible = 0 
    for x in electives:
      print(x)

  if free_elective != []: 
    if free_elective[1] == free_elective[2]: 
      uoc_remaining = free_elective[2]
    elif free_elective[2] == None:
      uoc_remaining = free_elective[1]
    #print(free_elective)
    uoc_remaining = uoc_remaining - (6*(in_list(free_elective[0], completed_courses, 0) - num_gen_eds(completed_courses)))
    
    if uoc_remaining > 0:
      if grad_eligible == 1: 
        print("\nRemaining to complete degree:")
        grad_eligible = 0

      if free_elective[1] == free_elective[2]:
        print(f"{uoc_remaining} UOC of Free Electives")
      elif free_elective[2] == None: 
        print(f"at least {uoc_remaining} UOC of Free Electives")
      else: # result[1] == None 
        print(f"{uoc_remaining} UOC of Free Electives")
    elif grad_eligible == 1: 
        print("\nEligible to Graduate")
        grad_eligible = 0 

  elif grad_eligible == 1: 
    print("\nEligible to Graduate")