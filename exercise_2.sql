SET SERVEROUTPUT ON;

-------------------------------------------------
-- Exercise 1: High Salary Report
-------------------------------------------------
DECLARE
    CURSOR c_emp IS
        SELECT e.emp_name,
               e.salary,
               d.dept_name
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        WHERE e.salary > (
            SELECT AVG(e2.salary)
            FROM employees e2
            WHERE e2.dept_id = e.dept_id
        );
    v_name      employees.emp_name%TYPE;
    v_salary    employees.salary%TYPE;
    v_dept_name departments.dept_name%TYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_name, v_salary, v_dept_name;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_salary || ' - ' || v_dept_name);
    END LOOP;
    CLOSE c_emp;
END;
/
-------------------------------------------------
-- Exercise 2: Salary Increment by Department (IT)
-------------------------------------------------
DECLARE
    CURSOR c_it IS
        SELECT emp_id, emp_name, salary
        FROM employees
        WHERE dept_id = (
            SELECT dept_id FROM departments WHERE UPPER(dept_name) = 'IT'
        );
    v_id     employees.emp_id%TYPE;
    v_name   employees.emp_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    OPEN c_it;
    LOOP
        FETCH c_it INTO v_id, v_name, v_salary;
        EXIT WHEN c_it%NOTFOUND;

        UPDATE employees
        SET salary = v_salary * 1.10
        WHERE emp_id = v_id;

        DBMS_OUTPUT.PUT_LINE(v_name || ' new salary: ' || (v_salary * 1.10));
    END LOOP;
    CLOSE c_it;
    COMMIT;
END;
/
-------------------------------------------------
-- Exercise 3: Customer Orders Summary (last 30 days)
-------------------------------------------------
DECLARE
    CURSOR c_cust IS
        SELECT c.customer_id,
               c.customer_name,
               COUNT(o.order_id) AS total_orders,
               SUM(o.total_amount) AS total_amount
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.order_date >= TRUNC(SYSDATE) - 30
        GROUP BY c.customer_id, c.customer_name;
    v_id          customers.customer_id%TYPE;
    v_name        customers.customer_name%TYPE;
    v_total_ord   NUMBER;
    v_total_amt   NUMBER;
BEGIN
    OPEN c_cust;
    LOOP
        FETCH c_cust INTO v_id, v_name, v_total_ord, v_total_amt;
        EXIT WHEN c_cust%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' -> Orders: ' || v_total_ord ||
                             ', Amount: ' || v_total_amt);
    END LOOP;
    CLOSE c_cust;
END;
/
-------------------------------------------------
-- Exercise 4: Pending Payments Reminder (overdue > 60 days)
-------------------------------------------------
DECLARE
    CURSOR c_inv IS
        SELECT i.invoice_id,
               i.customer_id,
               i.due_date,
               i.pending_amount,
               c.customer_name
        FROM invoices i
        JOIN customers c ON i.customer_id = c.customer_id
        WHERE i.status = 'PENDING'
          AND i.due_date < TRUNC(SYSDATE) - 60;
    v_invoice_id    invoices.invoice_id%TYPE;
    v_cust_id       invoices.customer_id%TYPE;
    v_due_date      invoices.due_date%TYPE;
    v_pending       invoices.pending_amount%TYPE;
    v_cust_name     customers.customer_name%TYPE;
BEGIN
    OPEN c_inv;
    LOOP
        FETCH c_inv INTO v_invoice_id, v_cust_id, v_due_date, v_pending, v_cust_name;
        EXIT WHEN c_inv%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cust_name || ' - Invoice: ' || v_invoice_id ||
                             ', Due: ' || TO_CHAR(v_due_date,'YYYY-MM-DD') ||
                             ', Pending: ' || v_pending);
    END LOOP;
    CLOSE c_inv;
END;
/
-------------------------------------------------
-- Exercise 5: Top 3 Employees per Department
-------------------------------------------------
DECLARE
    CURSOR c_top IS
        SELECT dept_name, emp_name, salary
        FROM (
            SELECT d.dept_name,
                   e.emp_name,
                   e.salary,
                   ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rn
            FROM employees e
            JOIN departments d ON e.dept_id = d.dept_id
        )
        WHERE rn <= 3
        ORDER BY dept_name, salary DESC;
    v_dept  departments.dept_name%TYPE;
    v_name  employees.emp_name%TYPE;
    v_sal   employees.salary%TYPE;
BEGIN
    OPEN c_top;
    LOOP
        FETCH c_top INTO v_dept, v_name, v_sal;
        EXIT WHEN c_top%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dept || ' - ' || v_name || ' - ' || v_sal);
    END LOOP;
    CLOSE c_top;
END;
/
-------------------------------------------------
-- Exercise 6: Low Stock Alert
-------------------------------------------------
DECLARE
    CURSOR c_prod IS
        SELECT product_name, category, stock_qty
        FROM products
        WHERE stock_qty < 10;
    v_name   products.product_name%TYPE;
    v_cat    products.category%TYPE;
    v_stock  products.stock_qty%TYPE;
BEGIN
    OPEN c_prod;
    LOOP
        FETCH c_prod INTO v_name, v_cat, v_stock;
        EXIT WHEN c_prod%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' (' || v_cat || ') - Stock: ' || v_stock);
    END LOOP;
    CLOSE c_prod;
END;
/
-------------------------------------------------
-- Exercise 7: Student Performance Report (below class average)
-------------------------------------------------
DECLARE
    v_avg NUMBER;
    CURSOR c_low IS
        SELECT s.student_name,
               e.subject,
               e.marks
        FROM exam_results e
        JOIN students s ON e.student_id = s.student_id
        WHERE e.exam_date = (SELECT MAX(exam_date) FROM exam_results)
          AND e.marks < v_avg;
    v_name   students.student_name%TYPE;
    v_sub    exam_results.subject%TYPE;
    v_marks  exam_results.marks%TYPE;
BEGIN
    SELECT AVG(marks)
    INTO v_avg
    FROM exam_results
    WHERE exam_date = (SELECT MAX(exam_date) FROM exam_results);

    OPEN c_low;
    LOOP
        FETCH c_low INTO v_name, v_sub, v_marks;
        EXIT WHEN c_low%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || v_sub || ' - ' || v_marks);
    END LOOP;
    CLOSE c_low;
END;
/
-------------------------------------------------
-- Exercise 8: Employee Anniversary (5, 10, 15 years this month)
-------------------------------------------------
DECLARE
    CURSOR c_ann IS
        SELECT emp_name,
               hire_date,
               TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS years_done
        FROM employees
        WHERE TO_CHAR(hire_date,'MM') = TO_CHAR(SYSDATE,'MM')
          AND TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) IN (5,10,15);
    v_name  employees.emp_name%TYPE;
    v_hire  employees.hire_date%TYPE;
    v_years NUMBER;
BEGIN
    OPEN c_ann;
    LOOP
        FETCH c_ann INTO v_name, v_hire, v_years;
        EXIT WHEN c_ann%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - ' || TO_CHAR(v_hire,'YYYY-MM-DD') ||
                             ' - ' || v_years || ' years');
    END LOOP;
    CLOSE c_ann;
END;
/
-------------------------------------------------
-- Exercise 9: Monthly Sales Commission (5%)
-------------------------------------------------
DECLARE
    CURSOR c_sales IS
        SELECT e.emp_name,
               e.emp_id,
               SUM(s.sale_amount) AS total_sales
        FROM employees e
        JOIN sales s ON e.emp_id = s.emp_id
        WHERE TRUNC(s.sale_date,'MM') = TRUNC(SYSDATE,'MM')
        GROUP BY e.emp_name, e.emp_id;
    v_name   employees.emp_name%TYPE;
    v_id     employees.emp_id%TYPE;
    v_sales  NUMBER;
    v_comm   NUMBER;
BEGIN
    OPEN c_sales;
    LOOP
        FETCH c_sales INTO v_name, v_id, v_sales;
        EXIT WHEN c_sales%NOTFOUND;
        v_comm := v_sales * 0.05;
        DBMS_OUTPUT.PUT_LINE(v_name || ' - Sales: ' || v_sales ||
                             ' - Commission: ' || v_comm);
    END LOOP;
    CLOSE c_sales;
END;
/
-------------------------------------------------
-- Exercise 10: Unused Accounts Cleanup (>1 year inactive)
-------------------------------------------------
DECLARE
    CURSOR c_acc IS
        SELECT user_id, username
        FROM user_accounts
        WHERE last_login_date < ADD_MONTHS(TRUNC(SYSDATE), -12)
          AND status <> 'Inactive';
    v_user_id user_accounts.user_id%TYPE;
    v_username user_accounts.username%TYPE;
BEGIN
    OPEN c_acc;
    LOOP
        FETCH c_acc INTO v_user_id, v_username;
        EXIT WHEN c_acc%NOTFOUND;

        UPDATE user_accounts
        SET status = 'Inactive'
        WHERE user_id = v_user_id;

        DBMS_OUTPUT.PUT_LINE('Marked inactive: ' || v_username);
    END LOOP;
    CLOSE c_acc;
    COMMIT;
END;
/
-------------------------------------------------
-- Exercise 11: Department Salary Budget Check
-------------------------------------------------
DECLARE
    CURSOR c_budget IS
        SELECT d.dept_name,
               SUM(e.salary) AS total_sal
        FROM employees e
        JOIN departments d ON e.dept_id = d.dept_id
        GROUP BY d.dept_name;
    v_dept   departments.dept_name%TYPE;
    v_total  NUMBER;
BEGIN
    OPEN c_budget;
    LOOP
        FETCH c_budget INTO v_dept, v_total;
        EXIT WHEN c_budget%NOTFOUND;

        IF v_total > 50000 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: ' || v_dept ||
                                 ' salary budget = ' || v_total);
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_dept || ' salary budget = ' || v_total);
        END IF;
    END LOOP;
    CLOSE c_budget;
END;
/
-------------------------------------------------
-- Exercise 12: Employee Promotion Eligibility
-------------------------------------------------
DECLARE
    CURSOR c_prom IS
        SELECT e.emp_name,
               e.salary,
               e.dept_id,
               TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS years_worked
        FROM employees e;
    v_name   employees.emp_name%TYPE;
    v_sal    employees.salary%TYPE;
    v_dept   employees.dept_id%TYPE;
    v_years  NUMBER;
    v_avg    NUMBER;
BEGIN
    OPEN c_prom;
    LOOP
        FETCH c_prom INTO v_name, v_sal, v_dept, v_years;
        EXIT WHEN c_prom%NOTFOUND;

        SELECT AVG(salary)
        INTO v_avg
        FROM employees
        WHERE dept_id = v_dept;

        IF v_years > 5 AND v_sal < v_avg THEN
            DBMS_OUTPUT.PUT_LINE(v_name || ' - Eligible for Promotion');
        END IF;
    END LOOP;
    CLOSE c_prom;
END;
/
-------------------------------------------------
-- Exercise 13: Customer Loyalty Program (parameterized cursor)
-------------------------------------------------
DECLARE
    v_cust_id customers.customer_id%TYPE := 1;

    CURSOR c_orders (p_cust_id customers.customer_id%TYPE) IS
        SELECT order_id, total_amount
        FROM orders
        WHERE customer_id = p_cust_id;

    v_order_id    orders.order_id%TYPE;
    v_total_amt   orders.total_amount%TYPE;
    v_points      NUMBER;
BEGIN
    OPEN c_orders(v_cust_id);
    LOOP
        FETCH c_orders INTO v_order_id, v_total_amt;
        EXIT WHEN c_orders%NOTFOUND;

        v_points := v_total_amt / 10;
        DBMS_OUTPUT.PUT_LINE('Order ' || v_order_id ||
                             ' - Amount: ' || v_total_amt ||
                             ' - Points: ' || v_points);
    END LOOP;
    CLOSE c_orders;
END;
/
-------------------------------------------------
-- Exercise 14: Invoice Penalty Calculation
-------------------------------------------------
DECLARE
    CURSOR c_pen IS
        SELECT invoice_id,
               pending_amount,
               due_date
        FROM invoices
        WHERE status = 'PENDING'
          AND due_date < TRUNC(SYSDATE);
    v_inv_id   invoices.invoice_id%TYPE;
    v_pending  invoices.pending_amount%TYPE;
    v_due      invoices.due_date%TYPE;
    v_months   NUMBER;
    v_penalty  NUMBER;
    v_total    NUMBER;
BEGIN
    OPEN c_pen;
    LOOP
        FETCH c_pen INTO v_inv_id, v_pending, v_due;
        EXIT WHEN c_pen%NOTFOUND;

        v_months := FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), v_due));
        IF v_months < 0 THEN
            v_months := 0;
        END IF;

        v_penalty := v_pending * 0.02 * v_months;
        v_total := v_pending + v_penalty;

        DBMS_OUTPUT.PUT_LINE('Invoice ' || v_inv_id ||
                             ' -> Pending: ' || v_pending ||
                             ', Months overdue: ' || v_months ||
                             ', Total with penalty: ' || v_total);
    END LOOP;
    CLOSE c_pen;
END;
/
-------------------------------------------------
-- Exercise 15: Product Restocking Suggestion (Electronics)
-------------------------------------------------
DECLARE
    CURSOR c_ele IS
        SELECT product_name, stock_qty
        FROM products
        WHERE UPPER(category) = 'ELECTRONICS';
    v_name  products.product_name%TYPE;
    v_stock products.stock_qty%TYPE;
    v_status VARCHAR2(20);
BEGIN
    OPEN c_ele;
    LOOP
        FETCH c_ele INTO v_name, v_stock;
        EXIT WHEN c_ele%NOTFOUND;

        IF v_stock < 10 THEN
            v_status := 'Critical';
        ELSIF v_stock BETWEEN 10 AND 50 THEN
            v_status := 'Low';
        ELSE
            v_status := 'OK';
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Stock: ' || v_stock ||
                             ' - ' || v_status);
    END LOOP;
    CLOSE c_ele;
END;
/
-------------------------------------------------
-- Exercise 16: Monthly Sales Performance
-------------------------------------------------
DECLARE
    CURSOR c_perf IS
        SELECT e.emp_name,
               e.emp_id,
               SUM(s.sale_amount) AS total_sales
        FROM employees e
        JOIN sales s ON e.emp_id = s.emp_id
        WHERE TRUNC(s.sale_date,'MM') = TRUNC(SYSDATE,'MM')
        GROUP BY e.emp_name, e.emp_id;
    v_name   employees.emp_name%TYPE;
    v_id     employees.emp_id%TYPE;
    v_sales  NUMBER;
    v_mark   VARCHAR2(30);
BEGIN
    OPEN c_perf;
    LOOP
        FETCH c_perf INTO v_name, v_id, v_sales;
        EXIT WHEN c_perf%NOTFOUND;

        IF v_sales < 5000 THEN
            v_mark := 'Needs Improvement';
        ELSE
            v_mark := 'Good Performer';
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Sales: ' || v_sales ||
                             ' - ' || v_mark);
    END LOOP;
    CLOSE c_perf;
END;
/
-------------------------------------------------
-- Exercise 17: Employee Bonus Distribution
-------------------------------------------------
DECLARE
    CURSOR c_bonus IS
        SELECT emp_name, salary
        FROM employees;
    v_name  employees.emp_name%TYPE;
    v_sal   employees.salary%TYPE;
    v_bonus NUMBER;
BEGIN
    OPEN c_bonus;
    LOOP
        FETCH c_bonus INTO v_name, v_sal;
        EXIT WHEN c_bonus%NOTFOUND;

        IF v_sal < 1000 THEN
            v_bonus := v_sal * 0.15;
        ELSIF v_sal BETWEEN 1000 AND 2000 THEN
            v_bonus := v_sal * 0.10;
        ELSE
            v_bonus := v_sal * 0.05;
        END IF;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Salary: ' || v_sal ||
                             ' - Bonus: ' || v_bonus);
    END LOOP;
    CLOSE c_bonus;
END;
/
-------------------------------------------------
-- Exercise 18: High Value Customer Detection
-------------------------------------------------
DECLARE
    CURSOR c_hvc IS
        SELECT c.customer_name,
               COUNT(o.order_id) AS ord_count,
               SUM(o.total_amount) AS total_val
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        GROUP BY c.customer_name
        HAVING SUM(o.total_amount) > 10000;
    v_name    customers.customer_name%TYPE;
    v_count   NUMBER;
    v_total   NUMBER;
BEGIN
    OPEN c_hvc;
    LOOP
        FETCH c_hvc INTO v_name, v_count, v_total;
        EXIT WHEN c_hvc%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_name || ' - Orders: ' || v_count ||
                             ' - Total: ' || v_total);
    END LOOP;
    CLOSE c_hvc;
END;
/
