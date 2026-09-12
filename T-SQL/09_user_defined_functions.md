# Section 9: User Defined Functions (UDFs)

Unlike Stored Procedures, User Defined Functions must return a value (scalar or tabular structural block) and cannot perform state-changing side effects (no `INSERT`, `UPDATE`, or `DELETE` updates to disk data rows).

## 1. Scalar UDFs
Returns a single primitive value.

```sql
CREATE FUNCTION fnCalculateAge (@DateOfBirth DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE()) - 
               CASE 
                   WHEN (MONTH(@DateOfBirth) > MONTH(GETDATE())) OR 
                        (MONTH(@DateOfBirth) = MONTH(GETDATE()) AND DAY(@DateOfBirth) > DAY(GETDATE())) 
                   THEN 1 
                   ELSE 0 
               END;
    RETURN @Age;
END;
GO

-- Usage in a SELECT query evaluation
SELECT Name, dbo.fnCalculateAge(DateOfBirth) AS CurrentAge FROM tblEmployee;
```

## 2. Inline Table-Valued Functions (ILTVFs)
Returns a table structure derived from a single execution block `RETURN (SELECT ...)`. Performance is highly optimized because SQL Server treats it as a view snippet.

```sql
CREATE FUNCTION fnGetEmployeesByGender (@Gender NVARCHAR(10))
RETURNS TABLE
AS
RETURN (
    SELECT Id, Name, Gender, Salary 
    FROM tblEmployee 
    WHERE Gender = @Gender
);
GO

-- Usage standard (Treated identical to a real storage table)
SELECT * FROM dbo.fnGetEmployeesByGender('Female');
```

## 3. Multi-Statement Table-Valued Functions (MSTVFs)
Returns a table structure whose layout is explicitly declared in the function signature. It uses a procedural `BEGIN...END` block to populate a temporary table variable before returning.

```sql
CREATE FUNCTION fnGetEmployeesWithSummary()
RETURNS @ResultsTable TABLE (Id INT, Name VARCHAR(50), Note VARCHAR(20))
AS
BEGIN
    INSERT INTO @ResultsTable
    SELECT Id, Name, 'Active Worker' FROM tblEmployee WHERE Salary >= 4000;
    
    INSERT INTO @ResultsTable
    SELECT Id, Name, 'Entry Level' FROM tblEmployee WHERE Salary < 4000;
    
    RETURN;
END;
```
