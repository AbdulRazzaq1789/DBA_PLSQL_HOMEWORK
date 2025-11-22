SET SERVEROUTPUT ON;

----------------------------
-- IF CONDITIONS
----------------------------

-- 1. Salary Adjustment Policy
DECLARE
    v_emp_id   employees.emp_id%TYPE := 101;
    v_salary   employees.salary%TYPE;
    v_new_sal  employees.salary%TYPE;
BEGIN
    SELECT salary
    INTO v_salary
    FROM employees
    WHERE emp_id = v_emp_id;

    IF v_salary < 30000 THEN
        v_new_sal := v_salary * 1.15;
    ELSIF v_salary BETWEEN 30000 AND 50000 THEN
        v_new_sal := v_salary * 1.10;
    ELSE
        v_new_sal := v_salary * 1.05;
    END IF;

    UPDATE employees
    SET salary = v_new_sal
    WHERE emp_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Old salary: ' || v_salary || ' New salary: ' || v_new_sal);
    COMMIT;
END;
/
----------------------------

-- 2. Exam Grading System
DECLARE
    v_marks NUMBER := 78;
    v_result VARCHAR2(20);
BEGIN
    IF v_marks >= 90 THEN
        v_result := 'Excellent';
    ELSIF v_marks BETWEEN 70 AND 89 THEN
        v_result := 'Good';
    ELSIF v_marks BETWEEN 50 AND 69 THEN
        v_result := 'Pass';
    ELSE
        v_result := 'Fail';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Marks: ' || v_marks || ' -> ' || v_result);
END;
/
----------------------------

-- 3. Loan Eligibility Check
DECLARE
    v_salary NUMBER := 45000;
    v_age    NUMBER := 35;
BEGIN
    IF v_salary > 40000 AND v_age < 60 THEN
        DBMS_OUTPUT.PUT_LINE('Eligible for loan');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Not Eligible');
    END IF;
END;
/
----------------------------

-- 4. Stock Discount Application
DECLARE
    v_price      NUMBER := 8500;
    v_discount   NUMBER := 0;
    v_final      NUMBER;
BEGIN
    IF v_price > 10000 THEN
        v_discount := v_price * 0.20;
    ELSIF v_price BETWEEN 5000 AND 10000 THEN
        v_discount := v_price * 0.10;
    END IF;

    v_final := v_price - v_discount;
    DBMS_OUTPUT.PUT_LINE('Original: ' || v_price ||
                         ' Discount: ' || v_discount ||
                         ' Final: ' || v_final);
END;
/
----------------------------

-- 5. Employee Bonus Allocation
DECLARE
    v_emp_id   employees.emp_id%TYPE := 101;
    v_hiredate employees.hire_date%TYPE;
    v_years    NUMBER;
    v_bonus    NUMBER;
BEGIN
    SELECT hire_date
    INTO v_hiredate
    FROM employees
    WHERE emp_id = v_emp_id;

    v_years := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hiredate) / 12);

    IF v_years > 5 THEN
        v_bonus := 5000;
    ELSE
        v_bonus := 2000;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Years: ' || v_years || ' Bonus: ' || v_bonus);
END;
/
----------------------------
-- LOOP
----------------------------

-- 6. ATM Cash Dispensing
DECLARE
    v_amount NUMBER := 7650;
    n500 NUMBER := 0;
    n100 NUMBER := 0;
    n50  NUMBER := 0;
BEGIN
    WHILE v_amount >= 500 LOOP
        n500 := n500 + 1;
        v_amount := v_amount - 500;
    END LOOP;

    WHILE v_amount >= 100 LOOP
        n100 := n100 + 1;
        v_amount := v_amount - 100;
    END LOOP;

    WHILE v_amount >= 50 LOOP
        n50 := n50 + 1;
        v_amount := v_amount - 50;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('500: ' || n500 || ' 100: ' || n100 || ' 50: ' || n50);
END;
/
----------------------------

-- 7. Restaurant Bill Calculation
DECLARE
    v_total NUMBER := 0;
    v_price NUMBER;
BEGIN
    FOR i IN 1..5 LOOP
        IF i = 1 THEN
            v_price := 150;
        ELSIF i = 2 THEN
            v_price := 200;
        ELSIF i = 3 THEN
            v_price := 120;
        ELSIF i = 4 THEN
            v_price := 90;
        ELSE
            v_price := 300;
        END IF;

        v_total := v_total + v_price;
        DBMS_OUTPUT.PUT_LINE('Item ' || i || ' price: ' || v_price);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total bill = ' || v_total);
END;
/
----------------------------

-- 8. Cinema Ticket Booking
DECLARE
    v_start_seat NUMBER := 21;
    v_seats      NUMBER := 10;
    v_end_seat   NUMBER;
BEGIN
    v_end_seat := v_start_seat + v_seats - 1;

    FOR s IN v_start_seat..v_end_seat LOOP
        DBMS_OUTPUT.PUT_LINE('Seat booked: ' || s);
    END LOOP;
END;
/
----------------------------

-- 9. Electricity Bill Slab Calculation
DECLARE
    v_units NUMBER := 350;
    v_bill  NUMBER := 0;
BEGIN
    FOR u IN 1..v_units LOOP
        IF u <= 100 THEN
            v_bill := v_bill + 3;
        ELSIF u <= 300 THEN
            v_bill := v_bill + 5;
        ELSE
            v_bill := v_bill + 7;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Units: ' || v_units || ' Bill: ' || v_bill || ' AFN');
END;
/
----------------------------

-- 10. Library Late Fees
DECLARE
    v_days NUMBER := 9;
    v_fine NUMBER := 0;
BEGIN
    FOR d IN 1..v_days LOOP
        IF d <= 5 THEN
            v_fine := v_fine + 10;
        ELSE
            v_fine := v_fine + 20;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Days late: ' || v_days || ' Fine: ' || v_fine || ' AFN');
END;
/
----------------------------

-- 11. Bank Interest Accumulation (compound yearly)
DECLARE
    v_principal NUMBER := 10000;
    v_rate      NUMBER := 8;   -- 8%
    v_years     NUMBER := 5;
    v_amount    NUMBER;
BEGIN
    v_amount := v_principal;

    FOR y IN 1..v_years LOOP
        v_amount := v_amount * (1 + v_rate / 100);
        DBMS_OUTPUT.PUT_LINE('Year ' || y || ' Amount: ' || v_amount);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Final amount after ' || v_years || ' years = ' || v_amount);
END;
/
----------------------------

-- 12. Student Attendance Record
DECLARE
    v_status VARCHAR2(10);
BEGIN
    FOR d IN 1..30 LOOP
        IF d IN (2,5,7,10) THEN
            v_status := 'Absent';
        ELSE
            v_status := 'Present';
        END IF;

        DBMS_OUTPUT.PUT_LINE('Day ' || d || ': ' || v_status);
    END LOOP;
END;
/
----------------------------
-- CURSOR
----------------------------

-- 13. List Employees in a Department
DECLARE
    v_dept_id employees.dept_id%TYPE := 10;
    CURSOR c_emp IS
        SELECT emp_name, salary
        FROM employees
        WHERE dept_id = v_dept_id;
    v_name   employees.emp_name%TYPE;
    v_sal    employees.salary%TYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_name, v_sal;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_sal);
    END LOOP;
    CLOSE c_emp;
END;
/
----------------------------

-- 14. Update Salaries in Bulk (Salesman)
DECLARE
    CURSOR c_sales IS
        SELECT emp_id, emp_name, salary
        FROM employees
        WHERE job_title = 'Salesman'
        FOR UPDATE;
    v_id   employees.emp_id%TYPE;
    v_name employees.emp_name%TYPE;
    v_sal  employees.salary%TYPE;
BEGIN
    OPEN c_sales;
    LOOP
        FETCH c_sales INTO v_id, v_name, v_sal;
        EXIT WHEN c_sales%NOTFOUND;

        UPDATE employees
        SET salary = v_sal + 2000
        WHERE CURRENT OF c_sales;

        DBMS_OUTPUT.PUT_LINE('Updated: ' || v_name || ' New salary: ' || (v_sal + 2000));
    END LOOP;
    CLOSE c_sales;
    COMMIT;
END;
/
----------------------------

-- 15. Top Student Finder (highest GPA per class)
DECLARE
    CURSOR c_class IS
        SELECT DISTINCT class_id
        FROM students;
    v_class   students.class_id%TYPE;
    v_name    students.student_name%TYPE;
    v_gpa     students.gpa%TYPE;
BEGIN
    OPEN c_class;
    LOOP
        FETCH c_class INTO v_class;
        EXIT WHEN c_class%NOTFOUND;

        SELECT student_name, gpa
        INTO v_name, v_gpa
        FROM students
        WHERE class_id = v_class
          AND gpa = (SELECT MAX(gpa) FROM students WHERE class_id = v_class)
          AND ROWNUM = 1;

        DBMS_OUTPUT.PUT_LINE('Class ' || v_class || ' -> ' || v_name || ' (GPA: ' || v_gpa || ')');
    END LOOP;
    CLOSE c_class;
END;
/
----------------------------

-- 16. Customer Credit Check (unpaid > 5000)
DECLARE
    CURSOR c_cust IS
        SELECT c.customer_name,
               SUM(o.unpaid_amount) AS total_unpaid
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.unpaid_amount > 0
        GROUP BY c.customer_name
        HAVING SUM(o.unpaid_amount) > 5000;
    v_name   customers.customer_name%TYPE;
    v_unpaid NUMBER;
BEGIN
    OPEN c_cust;
    LOOP
        FETCH c_cust INTO v_name, v_unpaid;
        EXIT WHEN c_cust%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' -> Unpaid: ' || v_unpaid);
    END LOOP;
    CLOSE c_cust;
END;
/
----------------------------

-- 17. Service Years Report
DECLARE
    CURSOR c_service IS
        SELECT emp_name, hire_date
        FROM employees;
    v_name  employees.emp_name%TYPE;
    v_hire  employees.hire_date%TYPE;
    v_years NUMBER;
BEGIN
    OPEN c_service;
    LOOP
        FETCH c_service INTO v_name, v_hire;
        EXIT WHEN c_service%NOTFOUND;

        v_years := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hire) / 12);
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_years || ' years');
    END LOOP;
    CLOSE c_service;
END;
/
----------------------------

-- 18. Low Stock Notification
DECLARE
    CURSOR c_stock IS
        SELECT product_id, product_name, stock_qty
        FROM products
        WHERE stock_qty < 10
        FOR UPDATE;
    v_id    products.product_id%TYPE;
    v_name  products.product_name%TYPE;
    v_qty   products.stock_qty%TYPE;
BEGIN
    OPEN c_stock;
    LOOP
        FETCH c_stock INTO v_id, v_name, v_qty;
        EXIT WHEN c_stock%NOTFOUND;

        UPDATE products
        SET status = 'Reorder Needed'
        WHERE CURRENT OF c_stock;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Stock: ' || v_qty || ' -> Reorder Needed');
    END LOOP;
    CLOSE c_stock;
    COMMIT;
END;
/
----------------------------

-- 19. Department Salary Report
DECLARE
    CURSOR c_dept IS
        SELECT d.dept_name,
               SUM(e.salary) AS total_sal
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        GROUP BY d.dept_name;
    v_dept  departments.dept_name%TYPE;
    v_total NUMBER;
BEGIN
    OPEN c_dept;
    LOOP
        FETCH c_dept INTO v_dept, v_total;
        EXIT WHEN c_dept%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dept || ' -> Total salary: ' || v_total);
    END LOOP;
    CLOSE c_dept;
END;
/
----------------------------

-- 20. Monthly Rent Collection
DECLARE
    CURSOR c_tenant IS
        SELECT t.tenant_name
        FROM tenants t
        WHERE NOT EXISTS (
            SELECT 1
            FROM rent_payments p
            WHERE p.tenant_id = t.tenant_id
              AND TRUNC(p.payment_date,'MM') = TRUNC(SYSDATE,'MM')
        );
    v_name tenants.tenant_name%TYPE;
BEGIN
    OPEN c_tenant;
    LOOP
        FETCH c_tenant INTO v_name;
        EXIT WHEN c_tenant%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reminder sent to: ' || v_name);
    END LOOP;
    CLOSE c_tenant;
END;
/
