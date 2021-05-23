
-- Part 1

CREATE TABLE fudgemart_agents (

    agent_id INT IDENTITY(1,1),
    agent_name VARCHAR(50) NOT NULL,
    agent_address VARCHAR(50) NOT NULL,
    agent_country VARCHAR(2) NOT NULL,
    agent_created_date DATETIME NOT NULL,
    agent_manager_id INT NOT NULL FOREIGN KEY REFERENCES fudgemart_employees(employee_id),
    agent_status BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (agent_id)

)

CREATE INDEX i_agent_country
ON fudgemart_agents(agent_country)

-- Câu 2



-- Câu 3

-- a.


SELECT employee_firstname + ' ' + employee_lastname AS fullname
FROM fudgemart_employees
WHERE employee_department = 'Electronics' AND YEAR(GETDATE()) - YEAR(employee_birthdate) > 30

-- b.

SELECT product_name
FROM fudgemart_products
WHERE product_is_active = 1 AND 2*product_wholesale_price = product_retail_price

-- Câu 4
-- a.

CREATE VIEW v_Mieky_active_products
AS
SELECT *
FROM fudgemart_products JOIN fudgemart_vendors ON product_vendor_id =  vendor_id
WHERE vendor_name = 'Mikey'


SELECT *
FROM v_Mieky_active_products

-- b.

-- Part 2

-- Câu 1

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
    IF EXISTS(SELECT * FROM fudgemart_employees WHERE employee_id = @id) RAISERROR('ID đã tồn tại',16,1)
    IF EXISTS(SELECT * FROM fudgemart_employees WHERE employee_ssn = @ssn) RAISERROR('SSN đã tồn tại',16,1)

    IF @jobtitle = 'CEO' 
        IF @hourlywage <= 50
            RAISERROR('Giờ công không hợp lệ (CEO)',16,1)
        ELSE 
            BEGIN
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
    END

    ELSE IF @jobtitle = 'Department Manager ' 
        IF @hourlywage < 30
            RAISERROR('Giờ công không hợp lệ (Manager)',16,1)
        ELSE
            BEGIN
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
    END

    ELSE IF @hourlywage >= 30
        RAISERROR('Giờ công không hợp lệ (NHAN VIEN THUONG)',16,1)

    ELSE 
    BEGIN
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
    END

    PRINT 'Insert thành công'
END;

DROP PROCEDURE p_fudgemart_add_new_employee

exec p_fudgemart_add_new_employee 70, 181369500, 'Bunn', 'Thomas', 'CEO', 'Electronics', '06/16/1982', '12/01/2008', 55 , 32


-- Câu 3

CREATE PROCEDURE p_fudgemart_update_hourlywage_employee
    @employee_id INT, 
    @hourlywage MONEY
AS
BEGIN

    DECLARE @superid INT;
    DECLARE @jobtitle INT;
    DECLARE @super_hourlywage INT;

    SELECT @superid = employee_supervisor_id
    FROM fudgemart_employees
    WHERE employee_id = @employee_id

    SELECT @jobtitle = employee_jobtitle
    FROM fudgemart_employees
    WHERE employee_id = @employee_id

    IF @superid <> NULL
    BEGIN
        SELECT @super_hourlywage = employee_hourlywage
        FROM fudgemart_employees
        WHERE employee_id = @superid

        IF @hourlywage > @super_hourlywage
        BEGIN 
            UPDATE fudgemart_employees
            SET employee_hourlywage = @super_hourlywage
            WHERE employee_id = @employee_id
        END
    END

    ELSE 

        IF @jobtitle = 'CEO' 
            IF @hourlywage < 50
                UPDATE fudgemart_employees
                SET employee_hourlywage = 50
                WHERE employee_id = @employee_id
            ELSE
                UPDATE fudgemart_employees
                SET employee_hourlywage = @hourlywage
                WHERE employee_id = @employee_id

        ELSE IF @jobtitle = 'Department Manager' 
            IF @hourlywage < 50 AND @hourlywage >= 30
                UPDATE fudgemart_employees
                SET employee_hourlywage = @hourlywage
                WHERE employee_id = @employee_id
            ELSE IF @hourlywage < 30
                UPDATE fudgemart_employees
                SET employee_hourlywage = 30
                WHERE employee_id = @employee_id
            ELSE IF @hourlywage > 50
                UPDATE fudgemart_employees
                SET employee_hourlywage = 50
                WHERE employee_id = @employee_id

        ELSE 
            IF @hourlywage > 30
                UPDATE fudgemart_employees
                SET employee_hourlywage = 30
                WHERE employee_id = @employee_id
            ELSE 
                UPDATE fudgemart_employees
                SET employee_hourlywage = @hourlywage
                WHERE employee_id = @employee_id

    
END

DROP PROCEDURE p_fudgemart_update_hourlywage_employee

EXEC p_fudgemart_update_hourlywage_employee 1, 35

-- Cau 4

CREATE TRIGGER t_fudgemart_update_hourlywage_employee
ON fudgemart_employees
INSTEAD OF UPDATE
AS
BEGIN

    DECLARE @superid INT;
    DECLARE @jobtitle INT;
    DECLARE @super_hourlywage INT;
    DECLARE @hourlywage INT;
    DECLARE @employee_id INT;

    SELECT @employee_id = employee_id
    FROM inserted

    SELECT @hourlywage = employee_hourlywage
    FROM inserted

    SELECT @superid = employee_supervisor_id
    FROM inserted

    SELECT @superid = employee_supervisor_id
    FROM inserted
   
    SELECT @jobtitle = employee_jobtitle
    FROM inserted
     

    IF @superid <> NULL
    BEGIN
        SELECT @super_hourlywage = employee_hourlywage
        FROM fudgemart_employees
        WHERE employee_id = @superid

        IF @hourlywage > @super_hourlywage
        BEGIN 
            UPDATE fudgemart_employees
            SET employee_hourlywage = @super_hourlywage
            WHERE employee_id = @employee_id
        END
    END

    ELSE 

        IF @jobtitle = 'CEO' 
            IF @hourlywage < 50
                UPDATE fudgemart_employees
                SET employee_hourlywage = 50
                WHERE employee_id = @employee_id
            ELSE
                UPDATE fudgemart_employees
                SET employee_hourlywage = @hourlywage
                WHERE employee_id = @employee_id

        ELSE IF @jobtitle = 'Department Manager' 
            IF @hourlywage < 50 AND @hourlywage >= 30
                UPDATE fudgemart_employees
                SET employee_hourlywage = @hourlywage
                WHERE employee_id = @employee_id
            ELSE IF @hourlywage < 30
                UPDATE fudgemart_employees
                SET employee_hourlywage = 30
                WHERE employee_id = @employee_id
            ELSE IF @hourlywage > 50
                UPDATE fudgemart_employees
                SET employee_hourlywage = 50
                WHERE employee_id = @employee_id

        ELSE 
            IF @hourlywage > 30
                UPDATE fudgemart_employees
                SET employee_hourlywage = 30
                WHERE employee_id = @employee_id
            ELSE 
                UPDATE fudgemart_employees
                SET employee_hourlywage = @hourlywage
                WHERE employee_id = @employee_id

END

UPDATE 

-- Cau 6

CREATE FUNCTION f_fudgemart_human_cost(
    @date_x DATETIME,
    @date_y DATETIME
)
RETURNS MONEY
AS
BEGIN
    DECLARE @result MONEY;
    DECLARE @ndate INT;

    SELECT  @result = SUM(employee_hourlywage*timesheet_hours)
    FROM fudgemart_employees JOIN fudgemart_employee_timesheets ON employee_id = timesheet_employee_id
    WHERE timesheet_payrolldate BETWEEN @date_x AND @date_y




    RETURN @result
END

DROP FUNCTION  f_fudgemart_human_cost

SELECT  dbo.f_fudgemart_human_cost('2006-01-01','2006-01-13') AS tong_luong



