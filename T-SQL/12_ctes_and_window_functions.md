# Section 12: CTEs, Transactions & Window Functions

## 1. Common Table Expressions (CTEs)
A CTE acts as a temporary named result set available exclusively within the execution span of a subsequent `SELECT`, `INSERT`, `UPDATE`, or `DELETE` statement.

* **Recursive CTE:** A configuration that references its own output, ideal for rendering organizational reporting hierarchies or structural parent-child loops.

```sql
-- Defining a clean CTE wrapper block
WITH EmployeeCount_CTE (DeptId, TotalEmployees)
AS (
    SELECT DepartmentId, COUNT(Id)
    FROM tblEmployee
    GROUP BY DepartmentId
)
SELECT D.DepartmentName, C.TotalEmployees
FROM tblDepartment D
INNER JOIN EmployeeCount_CTE C ON D.Id = C.DeptId;
```

---

## 2. Window Ranking Functions
Window functions calculate values across a partition framework of row balances without collapsing individual items into a single summary output row.

```sql
SELECT Name, Gender, Salary,
    ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS RowNum,
    RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS RankNum,
    DENSE_RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS DenseRankNum
FROM tblEmployee;
```
### Differences in Ranking Gaps:
* `ROW_NUMBER()`: Sequentially increments numerical counts unconditionally (`1, 2, 3, 4`).
* `RANK()`: Tied duplicate row items receive matching rank slots, skipping intervening counts to cause output sequence value **gaps** (`1, 2, 2, 4`).
* `DENSE_RANK()`: Duplicate records hold identical value ranks, but the numeric progression continues to the next sequential element without any **gaps** (`1, 2, 2, 3`).

---

## 3. Database Transactions (ACID Rules)
Transactions ensure complete operational isolation boundaries for sequence scripts. They either succeed collectively or rollback completely.

```sql
BEGIN TRY
    BEGIN TRANSACTION
        UPDATE tblAccount SET Balance = Balance - 500 WHERE AccountId = 1;
        UPDATE tblAccount SET Balance = Balance + 500 WHERE AccountId = 2;
    COMMIT TRANSACTION
    PRINT 'Transaction committed successfully.'
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT 'Error encountered. Transaction rolled back.'
END CATCH
```
