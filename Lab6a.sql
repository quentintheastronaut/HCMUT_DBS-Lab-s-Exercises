CREATE PROCEDURE p_fudgemart_add_new_employee
    @id INT,
    @ssn CHAR(9),
    @lastname VARCHAR(50),
    @firstname VARCHAR(50),
    @jobtitle VARCHAR(20),
    @department VARCHAR(20),
    @birthdate DATETIME,
    @hiredate DATETIME,
    @hourlywage MONEY,
    @supervisor_id INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT * FROM fudgemart_employees WHERE employee_id = @id) RETURN 0
    IF EXISTS(SELECT * FROM fudgemart_employees WHERE employee_ssn = @ssn) RETURN 0

    INSERT INTO fudgemart_employees (
        employee_id,
        employee_ssn,
        employee_lastname,
        employee_firstname,
        employee_jobtitle,
        employee_department,
        employee_birthdate,
        employee_hiredate,
        employee_hourlywage,
        employee_supervisor_id,
        employee_termdate
    )
    VALUES (
        @id,
        @ssn,
        @lastname,
        @firstname,
        @jobtitle,
        @department,
        @birthdate,
        @hiredate,
        @hourlywage,
        @supervisor_id,
        NULL

    )
END;

exec p_fudgemart_add_new_employee 40, 189563269, 'Bunn', 'Thomas', 'Department Manager', 'Electronics', '06/16/1982', '12/01/2008', 20.00, 32

CREATE PROCEDURE p_fudgemart_alter_payrate
    @amount DECIMAL(5,2),
    @ispercentage BIT
AS 
BEGIN 
    SET NOCOUNT ON;
    IF @ispercentage = 1
    BEGIN
        UPDATE fudgemart_employees
        SET employee_hourlywage = (1+@amount)*employee_hourlywage
    END

    ELSE
    BEGIN
        UPDATE fudgemart_employees
        SET employee_hourlywage = @amount + employee_hourlywage
    END
    RETURN @@ROWCOUNT
END;

exec p_fudgemart_alter_payrate .75, 0

exec p_fudgemart_alter_payrate -.05, 1



CREATE FUNCTION f_fudgemart_total_hours_worked
(
    @id INT
)

RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @result AS decimal(18,4)

    SET @result = (
        SELECT SUM(timesheet_hours)
        FROM fudgemart_employee_timesheets
        WHERE timesheet_employee_id = @id
    )
    RETURN @result
END


-- Lưu ý : cách tạo column cho một bảng với một function để lấy thuộc tính dẫn xuất.

ALTER TABLE dbo.fudgemart_employees 
ADD employee_total_hours 
AS dbo.f_fudgemart_total_hours_worked(employee_id)


CREATE VIEW v_fudgemart_active_employees
AS
SELECT * 
FROM fudgemart_employees
WHERE employee_termdate IS NULL AND employee_jobtitle <> 'Sales Associate'


SELECT employee_firstname + ' ' + employee_lastname AS 'employee name', employee_hourlywage
FROM v_fudgemart_active_employees
WHERE  employee_department = 'Customer Service'
ORDER BY employee_hourlywage


CREATE PROCEDURE p_fudgemart_display_weekly_timesheet
    @week DATETIME
AS
BEGIN
    SELECT 
        employee_ssn,
        employee_lastname,
        employee_firstname,
        employee_department,
        employee_hourlywage,
        timesheet_hours,
        timesheet_payrolldate

    FROM fudgemart_employees JOIN fudgemart_employee_timesheets
    ON employee_id = timesheet_employee_id
    WHERE timesheet_payrolldate = @week
END

exec p_fudgemart_display_weekly_timesheet '1/06/2006'

CREATE PROCEDURE p_fudgemart_delete_vendor
    @id INT
AS
BEGIN 
    IF EXISTS(
        SELECT *
        FROM fudgemart_products
        WHERE product_vendor_id = @id
    )

    BEGIN
        DELETE FROM fudgemart_products WHERE product_vendor_id=@id
    END

    DELETE FROM fudgemart_vendors WHERE vendor_id = @id

END

-- Lưu ý: khi không biết mã mà biết tên thì làm như sau

DECLARE @id INT;
SET @id = (
    SELECT vendor_id
    FROM fudgemart_vendors
    WHERE vendor_name = 'Fudgeman'

);

EXEC p_fudgemart_delete_vendor @id

CREATE VIEW v_fudgemart_display_active_products
AS
SELECT * 
FROM fudgemart_vendors JOIN fudgemart_products 
ON vendor_id = product_vendor_id
WHERE product_is_active = 'True'

SELECT product_name,product_wholesale_price
FROM v_fudgemart_display_active_products
WHERE product_is_active = 'True' AND vendor_name = 'Leaveeyes'

CREATE PROCEDURE p_fudgemart_get_managers_direct_reports
    @id INT
AS
BEGIN
    (
        SELECT employee_lastname + ' ' + employee_firstname AS employee_name, employee_ssn,employee_jobtitle
        FROM fudgemart_employees
        WHERE employee_supervisor_id = @id 
    )
END;

exec p_fudgemart_get_managers_direct_reports 32

CREATE PROCEDURE p_fudgemart_update_employee
    @id INT,
    @ssn CHAR(9),
    @lastname VARCHAR(50),
    @firstname VARCHAR(50),
    @jobtitle VARCHAR(20),
    @department VARCHAR(20),
    @birthdate DATETIME,
    @hiredate DATETIME,
    @hourlywage MONEY,
    @supervisor_id INT
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM fudgemart_employees WHERE employee_id = @id)
    UPDATE fudgemart_employees
    SET 
        employee_lastname = @lastname,
        employee_firstname = @firstname,
        employee_jobtitle = @jobtitle,
        employee_department = @department,
        employee_birthdate = @birthdate,
        employee_hiredate = @hiredate,
        employee_hourlywage = @hourlywage,
        employee_supervisor_id = @supervisor_id
    
    RETURN @@ROWCOUNT 

END

EXEC p_fudgemart_update_employee 40, '181369489' , 'Bunn', 'Thomas', 'Department Manager', 'Clothing', '06/16/1982', '12/01/2000', 26.75 , 32




SELECT * FROM fudgemart_products



CREATE PROCEDURE p_fudgemart_add_new_product

    @product_department VARCHAR(20),
    @product_name VARCHAR(50),
    @product_retail_price MONEY,
    @product_wholesale_price MONEY,
    @product_is_active BIT,
    @product_add_date DATETIME,
    @product_vendor_id INT

AS
BEGIN 
    
    INSERT INTO fudgemart_products(

        product_department,
        product_name,
        product_retail_price,
        product_wholesale_price,
        product_is_active,
        product_add_date,
        product_vendor_id,
        product_description
    )
    VALUES (
        
        @product_department,
        @product_name,
        @product_retail_price,
        @product_wholesale_price,
        @product_is_active,
        @product_add_date,
        @product_vendor_id,
        NULL
    )

    SET IDENTITY_INSERT [questions] OFF;

    
    
    RETURN @@ROWCOUNT

END


CREATE PROCEDURE p_fudgemart_deactivate_product
    @id INT
AS
BEGIN

    IF EXISTS( SELECT * FROM fudgemart_products WHERE product_id = @id)

    DECLARE @is_active BIT
    SET @is_active  = (
        SELECT product_is_active
        FROM fudgemart_products
        WHERE product_id = @id
    )

    IF @is_active <> 1
    BEGIN
        UPDATE fudgemart_products
        SET product_is_active = 1
        WHERE product_id = @id
    END

END;

CREATE PROCEDURE  p_fudgemart_terminate_employee
    @id INT 
AS
BEGIN
    IF EXISTS(SELECT * FROM fudgemart_employees WHERE employee_id = @id)
    UPDATE fudgemart_employees
    SET employee_termdate = GETDATE()
    WHERE employee_id = @id
END


EXEC p_fudgemart_terminate_employee 40


CREATE FUNCTION  f_fudgemart_vendor_product_count (
    @id INT
)
RETURNS INT
AS 
BEGIN 
    DECLARE @result INT
    IF EXISTS(SELECT * FROM fudgemart_vendors WHERE vendor_id = @id)
    BEGIN
    

    SET @result = (
        SELECT COUNT(product_vendor_id)
        FROM fudgemart_products
        WHERE product_vendor_id = @id
    )

    END

    RETURN @result


END 


exec f_fudgemart_vendor_product_count(10)

CREATE PROCEDURE p_fudgemart_delete_product
    @id INT
AS
BEGIN
    DELETE FROM fudgemart_products
    WHERE product_id = @id 
END


exec p_fudgemart_delete_product 53


CREATE DATABASE Lab5

-- Cau a
CREATE VIEW v_houston_staff_list
AS
SELECT ssn, fname + ' ' + lname AS fullname , pno , pname , [hours]
FROM ( Employee JOIN Works_on ON ssn = essn ) JOIN Project ON pno = pnumber
WHERE plocation = 'Houston'

SELECT * 
FROM v_houston_staff_list

-- Cau b

CREATE VIEW v_staff_have_more_two_dependent
AS
SELECT ssn ,fname + ' ' + lname AS fullname , COUNT(ssn) AS number_of_dependents
FROM Employee JOIN Dependent ON ssn = essn
GROUP BY ssn , fname ,lname
HAVING COUNT(ssn) > 2

SELECT * 
FROM v_staff_have_more_two_dependent

-- Cau c

CREATE VIEW v_july_staff
AS
SELECT fname + ' ' + lname AS fullname, bdate 
FROM Employee
WHERE MONTH(bdate) = 7
WITH CHECK OPTION;

SELECT * 
FROM v_july_staff


-- Cau 2a



-- Cau 2b

-- Cau 2c

CREATE TRIGGER t_update_salary
ON Works_on
AFTER UPDATE
AS
BEGIN
    DECLARE @gio_lam INT;
    DECLARE @id CHAR(9);

    SET @id = '123456789'

    SELECT @gio_lam = [hours], @id = essn
    FROM inserted

    IF @gio_lam > 40
    BEGIN
        UPDATE Employee
        SET salary = salary*1.25
        WHERE ssn = @id;
    END

END

DROP TRIGGER t_update_salary

UPDATE Works_on
SET [hours] = [hours] + 10
WHERE essn = '123456789'

-- Cau 3a 

SELECT * FROM Employee

CREATE PROCEDURE p_insert_employee
    @fname VARCHAR(15),
    @minit CHAR(1),
    @lname VARCHAR(15),
    @ssn CHAR(9),
    @bdate datetime,
    @address VARCHAR(30),
    @sex CHAR(1),
    @salary DECIMAL(10,2),
    @superssn CHAR(9),
    @dno INT
AS
BEGIN 
    IF EXISTS(SELECT * FROM Employee WHERE ssn = @ssn)
    BEGIN 
        RAISERROR('Da ton tai ssn',16,1)
    END

    INSERT INTO Employee

    VALUES (
        @fname ,
        @minit ,
        @lname ,
        @ssn ,
        @bdate, 
        @address ,
        @sex ,
        @salary, 
        @superssn, 
        @dno 
    )

    PRINT 'Insert thanh cong'
    

END

EXEC p_insert_employee 'John' ,'B' ,'Smith' , 181369479 , '1965-01-09', '731 Fondren, Houston, TX' ,'M',37500.00,333445555,5

CREATE FUNCTION f_count_project_staff(
    @id CHAR(9)
)
RETURNS INT 
AS
BEGIN
    DECLARE @nproject INT
    IF EXISTS(SELECT * FROM Employee WHERE ssn = @id)
        IF EXISTS(SELECT * FROM Works_on WHERE essn = @id)
        BEGIN
            SELECT @nproject = COUNT(essn)
            FROM Works_on
            WHERE essn = @id
            GROUP BY essn
        END
    
    RETURN @nproject
END

DROP FUNCTION f_count_project_staff

SELECT dbo.f_count_project_staff('333445555') AS SO_DU_AN

CREATE PROCEDURE p_staff_salary_year
AS
BEGIN
    SELECT ssn,fname+' '+lname AS fullname, dname, salary*12 AS years_salay
    FROM Employee JOIN Department ON dno = dnumber
END


EXEC p_staff_salary_year


