# Section 11: Database Views & Triggers Architecture

## 1. Database Views
A View is a virtual table representing a saved query definition layer. It provides security masking by hiding downstream structural column parameters.

* **Indexed View:** A view where a unique clustered index is applied, materializing query computational data directly to physical storage files for high efficiency.

```sql
CREATE VIEW vWEmployeesByDepartment
AS
SELECT E.Id, E.Name, D.DepartmentName
FROM tblEmployee E
INNER JOIN tblDepartment D ON E.DepartmentId = D.Id;
GO

-- Querying the virtual schema layout
SELECT * FROM vWEmployeesByDepartment;
```

---

## 2. DML Triggers
Triggers are automated block processes that fire instantly upon data manipulation statements executing against target structures (`INSERT`, `UPDATE`, `DELETE`). They make use of two special virtual ledger arrays: `Inserted` and `Deleted`.

* **AFTER/FOR Triggers:** Fires downstream *after* the initial data alteration logic succeeds.
* **INSTEAD OF Triggers:** Hijacks execution entirely, executing the trigger body logic *instead of* the initial DML statement block.

```sql
-- Logging deletions automatically through an AFTER DELETE trigger
CREATE TRIGGER trgAfterDeleteEmployee
ON tblEmployee
AFTER DELETE
AS
BEGIN
    INSERT INTO tblEmployeeAuditLog (DeletedEmployeeId, DeletionDate)
    SELECT Id, GETDATE() FROM Deleted
END;
```
