SET SERVEROUTPUT ON;

------------------------------------------------------------
-- 1. Basic & Variables
------------------------------------------------------------

-- 1) Annual Salary
DECLARE
    v_basic_salary  NUMBER := 30000;
    v_bonus         NUMBER := 5000;
    v_annual_salary NUMBER;
BEGIN
    v_annual_salary := v_basic_salary + v_bonus;
    DBMS_OUTPUT.PUT_LINE('Annual Salary = ' || v_annual_salary);
END;
/
------------------------------------------------------------

-- 2) Average of 3 subject marks
DECLARE
    v_sub1 NUMBER := 80;
    v_sub2 NUMBER := 75;
    v_sub3 NUMBER := 90;
    v_avg  NUMBER;
BEGIN
    v_avg := (v_sub1 + v_sub2 + v_sub3) / 3;
    DBMS_OUTPUT.PUT_LINE('Average Marks = ' || v_avg);
END;
/
------------------------------------------------------------

------------------------------------------------------------
-- 2. Conditional Statements
------------------------------------------------------------

-- 3) Bank balance check
DECLARE
    v_balance NUMBER := 4500;
BEGIN
    IF v_balance < 1000 THEN
        DBMS_OUTPUT.PUT_LINE('Low Balance');
    ELSIF v_balance BETWEEN 1000 AND 5000 THEN
        DBMS_OUTPUT.PUT_LINE('Sufficient Balance');
    ELSE
        DBMS_OUTPUT.PUT_LINE('High Balance');
    END IF;
END;
/
------------------------------------------------------------

-- 4) Grading system using CASE
DECLARE
    v_percentage NUMBER := 82;
    v_grade VARCHAR2(20);
BEGIN
    v_grade := CASE
        WHEN v_percentage BETWEEN 90 AND 100 THEN 'A Grade'
        WHEN v_percentage BETWEEN 75 AND 89 THEN 'B Grade'
        WHEN v_percentage BETWEEN 50 AND 74 THEN 'C Grade'
        ELSE 'Fail'
    END;

    DBMS_OUTPUT.PUT_LINE('Grade: ' || v_grade);
END;
/
------------------------------------------------------------

-- 5) Shopping discount
DECLARE
    v_bill NUMBER := 5200;
    v_discount NUMBER := 0;
    v_final NUMBER;
BEGIN
    IF v_bill > 5000 THEN
        v_discount := v_bill * 0.20;
    ELSIF v_bill BETWEEN 2000 AND 5000 THEN
        v_discount := v_bill * 0.10;
    END IF;

    v_final := v_bill - v_discount;

    DBMS_OUTPUT.PUT_LINE('Final Bill = ' || v_final);
END;
/
------------------------------------------------------------

------------------------------------------------------------
-- 3. Looping
------------------------------------------------------------

-- 6) Multiplication table
DECLARE
    v_num NUMBER := 7;
    i NUMBER := 1;
BEGIN
    WHILE i <= 10 LOOP
        DBMS_OUTPUT.PUT_LINE(v_num || ' x ' || i || ' = ' || (v_num * i));
        i := i + 1;
    END LOOP;
END;
/
------------------------------------------------------------

-- 7) Employee IDs 100 to 120
BEGIN
    FOR v_id IN 100..120 LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_id);
    END LOOP;
END;
/
------------------------------------------------------------

-- 8) Factorial using WHILE loop
DECLARE
    v_n NUMBER := 5;
    v_fact NUMBER := 1;
    i NUMBER := 1;
BEGIN
    WHILE i <= v_n LOOP
        v_fact := v_fact * i;
        i := i + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Factorial = ' || v_fact);
END;
/
------------------------------------------------------------

-- 9) Countdown 10 to 1
BEGIN
    FOR i IN REVERSE 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/
------------------------------------------------------------

------------------------------------------------------------
-- 4. Table-Based Scenarios
-- employees(emp_id, emp_name, salary, dept_id)
------------------------------------------------------------

-- 10) Print IT department employees
BEGIN
    FOR rec IN (
        SELECT emp_name FROM employees WHERE dept_id = 10
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('IT Employee: ' || rec.emp_name);
    END LOOP;
END;
/
------------------------------------------------------------

-- 11) Give 10% salary increase to employees with salary < 3000
DECLARE
    CURSOR c_emp IS
        SELECT emp_id, salary FROM employees WHERE salary < 3000;
BEGIN
    FOR rec IN c_emp LOOP
        UPDATE employees
        SET salary = rec.salary * 1.10
        WHERE emp_id = rec.emp_id;

        DBMS_OUTPUT.PUT_LINE(
            'Updated ' || rec.emp_id || ' -> ' || (rec.salary * 1.10)
        );
    END LOOP;

    COMMIT;
END;
/
------------------------------------------------------------

-- 12) Employees above average salary
DECLARE
    v_avg NUMBER;
BEGIN
    SELECT AVG(salary) INTO v_avg FROM employees;

    DBMS_OUTPUT.PUT_LINE('Average Salary = ' || v_avg);

    FOR rec IN (
        SELECT emp_id, emp_name, salary
        FROM employees
        WHERE salary > v_avg
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' -> ' || rec.salary);
    END LOOP;
END;
/
------------------------------------------------------------

-- 13) High / Mid / Low earner
BEGIN
    FOR rec IN (SELECT emp_name, salary FROM employees) LOOP
        IF rec.salary > 8000 THEN
            DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' = High Earner');
        ELSIF rec.salary BETWEEN 4000 AND 8000 THEN
            DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' = Mid Earner');
        ELSE
            DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' = Low Earner');
        END IF;
    END LOOP;
END;
/
------------------------------------------------------------

-- 14) Total salary cost by department
BEGIN
    FOR rec IN (
        SELECT dept_id, SUM(salary) AS total_salary
        FROM employees
        GROUP BY dept_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Dept ' || rec.dept_id || ' -> ' || rec.total_salary
        );
    END LOOP;
END;
/
------------------------------------------------------------

------------------------------------------------------------
-- 5. Challenge Level
------------------------------------------------------------

-- 15) Fibonacci sequence
DECLARE
    n NUMBER := 10;
    a NUMBER := 0;
    b NUMBER := 1;
    c NUMBER;
    i NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Fibonacci Series:');

    WHILE i <= n LOOP
        IF i = 1 THEN
            DBMS_OUTPUT.PUT_LINE(a);
        ELSIF i = 2 THEN
            DBMS_OUTPUT.PUT_LINE(b);
        ELSE
            c := a + b;
            DBMS_OUTPUT.PUT_LINE(c);
            a := b;
            b := c;
        END IF;

        i := i + 1;
    END LOOP;
END;
/
------------------------------------------------------------

-- 16) Bank transactions processing
DECLARE
    v_balance NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT txn_id, amount, type FROM transactions WHERE ROWNUM <= 100
    ) LOOP
        IF rec.type = 'CREDIT' THEN
            v_balance := v_balance + rec.amount;
        ELSIF rec.type = 'DEBIT' THEN
            v_balance := v_balance - rec.amount;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Final Balance = ' || v_balance);
END;
/
------------------------------------------------------------

-- 17) Procedure to print employee details
CREATE OR REPLACE PROCEDURE show_employee_details (
    p_emp_id IN NUMBER
) AS
    v_name employees.emp_name%TYPE;
    v_dept departments.dept_name%TYPE;
    v_sal  employees.salary%TYPE;
BEGIN
    SELECT e.emp_name, d.dept_name, e.salary
    INTO v_name, v_dept, v_sal
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    WHERE e.emp_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_dept);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_sal);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found.');
END;
/
------------------------------------------------------------

-- Run the procedure example
BEGIN
    show_employee_details(101);
END;
/
------------------------------------------------------------
