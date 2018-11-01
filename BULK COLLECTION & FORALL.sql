begin
--------------------------------------------------------------------
-- 1) BULK COLLECT 
--
-- 2) FORALL
--------------------------------------------------------------------  


--- 1
     department_id_in   IN employees.department_id%TYPE,
     increase_pct_in    IN NUMBER)
  IS
     TYPE employee_ids_t IS TABLE OF employees.employee_id%TYPE
             INDEX BY PLS_INTEGER; 
     l_employee_ids   employee_ids_t;
     l_eligible_ids   employee_ids_t;

     l_eligible       BOOLEAN;
  BEGIN
     SELECT employee_id
       BULK COLLECT INTO l_employee_ids
       FROM employees
      WHERE department_id = increase_salary.department_id_in;

     FOR indx IN 1 .. l_employee_ids.COUNT
     LOOP
        check_eligibility (l_employee_ids (indx),
                           increase_pct_in,
                           l_eligible);

        IF l_eligible
        THEN
           l_eligible_ids (l_eligible_ids.COUNT + 1) :=
              l_employee_ids (indx);
        END IF;
     END LOOP;

     FORALL indx IN 1 .. l_eligible_ids.COUNT
        UPDATE employees emp
           SET emp.salary =
                    emp.salary
                  + emp.salary * increase_salary.increase_pct_in
         WHERE emp.employee_id = l_eligible_ids (indx);
END;

--- 2

DECLARE

   TYPE two_cols_rt IS RECORD
   (
      employee_id   employees.employee_id%TYPE,
      salary        employees.salary%TYPE
   );
   
   TYPE employee_info_t IS TABLE OF two_cols_rt;
   
   l_employees   employee_info_t;
   
BEGIN
  
   SELECT employee_id, salary
     BULK COLLECT INTO l_employees
     FROM employees
    WHERE department_id = 10;
    
END;
