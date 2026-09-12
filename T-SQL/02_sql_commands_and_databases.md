# Section 2: SQL Commands & Database Lifecycle

## 1. Core Categories of SQL Commands
SQL statements are instructions categorized by their functional purpose:

* **Data Definition Language (DDL):** Defines, modifies, and drops structural database objects.
  * *Commands:* `CREATE`, `ALTER`, `DROP`, `RENAME`, `TRUNCATE`.
* **Data Manipulation Language (DML):** Handles storing, retrieving, modifying, and deleting row data.
  * *Commands:* `SELECT`, `INSERT`, `UPDATE`, `DELETE`.
* **Transaction Control Language (TCL):** Manages changes affecting transactional stability.
  * *Commands:* `COMMIT`, `ROLLBACK`, `SAVEPOINT`.
* **Data Control Language (DCL):** Manages permissions and security boundaries.
  * *Commands:* `GRANT`, `REVOKE`.

---

## 2. Database Creation & Storage Files
A SQL Server database is a collection of relational objects like tables, views, and stored procedures. Every database generates two mandatory physical files on the disk:
1. **.MDF File (Primary Data File):** Contains the actual database schema and data records.
2. **.LDF File (Transaction Log File):** Keeps a ledger of structural alterations and transactions to recover data in case of failure.

### Command Scripts:
```sql
-- Create a new database
CREATE DATABASE TestDB;

-- Rename an existing database
ALTER DATABASE TestDB MODIFY NAME = NewTestDB;

-- Alternative method using system stored procedure
EXEC sp_renameDB 'OldDatabaseName', 'NewDatabaseName';

-- Safely drop a database by forcing single-user mode first
ALTER DATABASE NewTestDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE NewTestDB;
```
