# Section 3: Database Backups & Recovery Operations

Backing up databases is essential for protecting business data against infrastructure failures. SQL Server mainly utilizes three distinct backup strategies.

## 1. T-SQL Scripted Backups
```sql
-- 1. Full Database Backup (Creates a complete snapshot copy)
BACKUP DATABASE TestDB 
TO DISK = 'D:\Backups\TestDB_Full.bak';

-- 2. Differential Backup (Captures only changes since the last Full backup)
BACKUP DATABASE TestDB 
TO DISK = 'D:\Backups\TestDB_Diff.bak' 
WITH DIFFERENTIAL;

-- 3. Transaction Log Backup (Records all transactional ledger updates)
BACKUP LOG TestDB 
TO DISK = 'D:\Backups\TestDB_Log.trn';
```

## 2. Restoring a Database
To recover or move a database from an existing target file patch, execute the restoration command structure:
```sql
RESTORE DATABASE TestDB 
FROM DISK = 'D:\Backups\TestDB_Full.bak';
```
