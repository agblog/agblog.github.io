# Section 7: Stored Procedures & Parameters

Stored Procedures are pre-compiled collections of SQL statements stored directly in the database engine. They reduce network traffic, provide security boundaries, and improve execution performance through query plan caching.

## 1. Basic Stored Procedure with Output Parameters
Output parameters allow a stored procedure to return a scalar value back to the calling application without generating a full result set.

```sql
-- Creating a procedure with an Input and Output parameter
CREATE PROCEDURE spGetEmployeeCountByGender
    @Gender NVARCHAR(20),       -- Input Parameter
    @EmployeeCount INT OUTPUT   -- Output Parameter
AS
BEGIN
    SELECT @EmployeeCount = COUNT(Id) 
    FROM tblEmployee 
    WHERE Gender = @Gender
END;
GO

-- Executing the procedure and retrieving the output value
DECLARE @TotalCount INT;

EXEC spGetEmployeeCountByGender 'Male', @TotalCount OUTPUT;

SELECT @TotalCount AS 'Total Male Employees';
```

## 2. Stored Procedures with Optional Parameters
You can provide default values to parameters during creation. If the user omits the parameter during execution, the database engine falls back to the default setup.

```sql
CREATE PROCEDURE spGetEmployeesByCity
    @City NVARCHAR(50) = 'London' -- Optional Parameter with default value
AS
BEGIN
    SELECT * FROM tblEmployee WHERE City = @City
END;
GO

-- Both execution methods are valid:
EXEC spGetEmployeesByCity;             -- Uses 'London'
EXEC spGetEmployeesByCity 'New York';  -- Overrides with 'New York'
```

## 3. Output Parameters vs. Return Values
* **Output Parameters:** Can return multiple data values of any relational data type (integers, strings, dates).
* **Return Values:** Can only return a single `INT` status value (typically used to communicate execution success `0` or failure error codes).
