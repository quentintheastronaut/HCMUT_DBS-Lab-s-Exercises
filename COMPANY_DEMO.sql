CREATE TABLE employee (
  emp_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  birth_day DATE,
  sex VARCHAR(1),
  salary INT,
  super_id INT,
  branch_id INT
);



CREATE TABLE branch (
  branch_id INT PRIMARY KEY,
  branch_name VARCHAR(40),
  mgr_id INT,
  mgr_start_date DATE,
  FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

ALTER TABLE employee
ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)
ON DELETE NO ACTION;

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE NO ACTION;

CREATE TABLE client (
  client_id INT PRIMARY KEY,
  client_name VARCHAR(40),
  branch_id INT,
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

CREATE TABLE works_with (
  emp_id INT,
  client_id INT,
  total_sales INT,
  PRIMARY KEY(emp_id, client_id),
  FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
  FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE branch_supplier (
  branch_id INT,
  supplier_name VARCHAR(40),
  supply_type VARCHAR(40),
  PRIMARY KEY(branch_id, supplier_name),
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);


-- -----------------------------------------------------------------------------

-- Corporate
INSERT INTO employee VALUES(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, NULL, NULL);
-- set null vì chưa nhập của hàng 1

INSERT INTO branch VALUES(1, 'Corporate', 100, '2006-02-09');
-- thêm branch 1 xong update

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;


INSERT INTO employee VALUES(101, 'Jan', 'Levinson', '1961-05-11', 'F', 110000, 100, 1);

-- Scranton
-- tương tự như ông đầu tiên
INSERT INTO employee VALUES(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, 100, NULL);

INSERT INTO branch VALUES(2, 'Scranton', 102, '1992-04-06');

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;



INSERT INTO employee VALUES(103, 'Angela', 'Martin', '1971-06-25', 'F', 63000, 102, 2);
INSERT INTO employee VALUES(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, 102, 2);
INSERT INTO employee VALUES(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, 102, 2);

-- Stamford
INSERT INTO employee VALUES(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, 100, NULL);

INSERT INTO branch VALUES(3, 'Stamford', 106, '1998-02-13');

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

INSERT INTO employee VALUES(107, 'Andy', 'Bernard', '1973-07-22', 'M', 65000, 106, 3);
INSERT INTO employee VALUES(108, 'Jim', 'Halpert', '1978-10-01', 'M', 71000, 106, 3);


-- BRANCH SUPPLIER
INSERT INTO branch_supplier VALUES(2, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Patriot Paper', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'J.T. Forms & Labels', 'Custom Forms');
INSERT INTO branch_supplier VALUES(3, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(3, 'Stamford Lables', 'Custom Forms');

-- CLIENT
INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);
INSERT INTO client VALUES(401, 'Lackawana Country', 2);
INSERT INTO client VALUES(402, 'FedEx', 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);
INSERT INTO client VALUES(405, 'Times Newspaper', 3);
INSERT INTO client VALUES(406, 'FedEx', 2);

-- WORKS_WITH
INSERT INTO works_with VALUES(105, 400, 55000);
INSERT INTO works_with VALUES(102, 401, 267000);
INSERT INTO works_with VALUES(108, 402, 22500);
INSERT INTO works_with VALUES(107, 403, 5000);
INSERT INTO works_with VALUES(108, 403, 12000);
INSERT INTO works_with VALUES(105, 404, 33000);
INSERT INTO works_with VALUES(107, 405, 26000);
INSERT INTO works_with VALUES(102, 406, 15000);
INSERT INTO works_with VALUES(105, 406, 130000);


SELECT * FROM employee;
SELECT * FROM branch;
SELECT * FROM works_with;
SELECT * FROM client;
SELECT * FROM branch_supplier;

-- a. Liệt kê danh sách tất cả nhân viên
SELECT * FROM employee;

-- b. Liệt kê nhân viên và lương của họ theo thứ tự tăng dần.
SELECT first_name,  last_name, salary
FROM employee
ORDER BY salary DESC;

-- c. Liệt kê nhân viên theo giới tính
SELECT first_name, last_name, sex
FROM employee
ORDER BY sex,first_name;

-- d. Liet ke 5 nhan vien dau tien
SELECT TOP 5 first_name,last_name
FROM employee;

-- e. tim he va ten cua nhan vien
SELECT first_name AS forename , last_name AS surname
FROM employee;

-- f. In cac gia tri cua branch_id
SELECT DISTINCT branch_id
FROM employee;

-- Tim so nhan vien
SELECT COUNT(emp_id) AS employee_number
FROM employee;

SELECT COUNT(super_id)
FROM employee ;

SELECT COUNT(emp_id)
FROM employee
WHERE sex = 'F' AND birth_day >= '1970-01-01'

SELECT AVG(salary) 
FROM employee
WHERE sex = 'M';

SELECT SUM(salary)
FROM employee;

-- So nam va so nu
SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;

-- Liet ke nhung nhan vien co sale va sale cua ho
SELECT SUM(total_sales) , emp_id
FROM works_with
GROUP BY emp_id;

SELECT SUM(total_sales) AS total_money , client_id
FROM works_with
GROUP BY client_id
ORDER BY total_money;

-- % = any char : mot string co phan dau la % va duoi STRING '%STRING'
-- _ = one char : 

SELECT * 
FROM branch_supplier
WHERE supplier_name LIKE '% Label_'

SELECT * 
FROM employee
WHERE birth_day LIKE '____-10%'

SELECT *
FROM client
WHERE client_name LIKE '%school%';


-- UNIQUE
SELECT first_name AS name
FROM employee
UNION
SELECT branch_name
FROM branch
UNION
SELECT client_name
FROM client;

SELECT client_name,branch_id
FROM client
UNION 
SELECT supplier_name,branch_id
FROM branch_supplier;

SELECT salary AS moneys
FROM employee
UNION 
SELECT total_sales
FROM works_with;

-- JOIN 


-- Lay ten cac quan ly va branch cua ho
SELECT employee.emp_id , employee.first_name , branch.branch_name
FROM employee JOIN branch
ON employee.emp_id = branch.mgr_id
ORDER BY branch_name DESC;

-- Cach 1
SELECT first_name, last_name
FROM employee JOIN works_with
ON employee.emp_id = works_with.emp_id
WHERE total_sales > 30000;

-- Cach 2
SELECT first_name, last_name
FROM employee
WHERE employee.emp_id IN (
    SELECT works_with.emp_id
    FROM works_with
    WHERE total_sales > 30000
);

SELECT client.client_name 
FROM client
WHERE branch_id IN (
    SELECT branch_id
    FROM employee
    WHERE employee.first_name = 'Michael' AND employee.last_name = 'Scott'
)

-- ON DELETE

-- Triggers

CREATE TABLE trigger_test (
    message VARCHAR(100)
);

-- Azure SQL Database Syntax   
-- Trigger on an INSERT, UPDATE, or DELETE statement to a table or view (DML Trigger)  
  
CREATE TRIGGER mytriggers   
ON employee
FOR INSERT 
AS 
BEGIN
    PRINT @employee.employee_name
    RETURN 1
END