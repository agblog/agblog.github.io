# Section 10: Temporary Tables, Variables & Indexes

## 1. Temporary Storage Frameworks
* **Local Temporary Tables (`#TableName`):** Stored in `tempdb`. Visible only to the current session connection. Destroyed automatically when the session closes.
* **Global Temporary Tables (`##TableName`):** Stored in `tempdb`. Visible across all concurrent system connections. Destroyed when all referencing sessions drop off.
* **Table Variables (`@TableVariable`):** Created in memory (can spill to `tempdb`). Scope is constrained strictly to the batch execution layer.

```sql
-- Creating a Local Temporary Table
CREATE TABLE #TempEmployee (
    Id INT,
    Name VARCHAR(50)
);
INSERT INTO #TempEmployee SELECT Id, Name FROM tblEmployee;
SELECT * FROM #TempEmployee;
DROP TABLE #TempEmployee;
```

---

## 2. Clustered vs. Non-Clustered Indexes
Indexes optimize table read execution time boundaries by minimizing execution tables scans.

* **Clustered Index:** Physically reorders data rows sequentially on disk records based on the index key. A table can possess **only one** clustered index configuration (automatically generated on the Primary Key).
* **Non-Clustered Index:** Stores index keys pointing back to physical row pointer coordinates separately from the actual tables. A table can possess **multiple** non-clustered index layouts.

```sql
-- Create a non-clustered index on frequently filtered columns
CREATE NONCLUSTERED INDEX IX_tblEmployee_Salary
ON tblEmployee (Salary ASC);
```
