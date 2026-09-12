# Section 6: Data Selection, GroupBy & Table Joins

## 1. Basic Data Selection & Filtering
```sql
-- Retrieve distinct records 
SELECT DISTINCT City FROM tblPerson;

-- Filter with Boolean criteria
SELECT Name, Email 
FROM tblPerson 
WHERE City = 'London' AND Age >= 21;

-- Pattern searching using LIKE wildcards
SELECT * FROM tblPerson WHERE Name LIKE 'S%';
```

---

## 2. Summarization with GROUP BY
The `GROUP BY` clause groups active records into summary blocks using aggregate functions like `SUM()`, `MIN()`, `MAX()`, `AVG()`, and `COUNT()`.

* **WHERE:** Filters raw rows *before* any aggregate calculations take place.
* **HAVING:** Filters summarized groups *after* evaluations are computed.

```sql
SELECT City, Gender, SUM(Salary) AS TotalSalary, COUNT(Id) AS TotalEmployees
FROM tblEmployee
WHERE Gender = 'Male'
GROUP BY City, Gender
HAVING SUM(Salary) > 5000;
```

---

## 3. Relational Joins Execution
Joins combine columns from matching source row tables utilizing common key boundaries.

```sql
-- 1. INNER JOIN: Returns matching rows present across BOTH tables.
SELECT E.Name, D.DepartmentName
FROM tblEmployee E
INNER JOIN tblDepartment D ON E.DepartmentId = D.Id;

-- 2. LEFT JOIN: Returns ALL left-table records + matched right records.
SELECT E.Name, D.DepartmentName
FROM tblEmployee E
LEFT JOIN tblDepartment D ON E.DepartmentId = D.Id;

-- 3. ADVANCED LEFT JOIN: Isolated left records only (Non-matching exclusion)
SELECT E.Name, D.DepartmentName
FROM tblEmployee E
LEFT JOIN tblDepartment D ON E.DepartmentId = D.Id
WHERE D.Id IS NULL;

-- 4. SELF JOIN: Query joining a table with itself (Requires distinct alias tokens)
SELECT E.Name AS Employee, M.Name AS Manager
FROM tblEmployee E
LEFT JOIN tblEmployee M ON E.ManagerId = M.EmployeeId;
```
