-- ========================================================================
-- RUNBOOK STEP 11: WORKLOAD SYNCHRONIZATION PIPELINE MIGRATIONS
-- ========================================================================

-- Execute on Primary Server Endpoint Configuration Connection Windows:
USE master;
GO

CREATE DATABASE EnterpriseAppDB ;
GO
ALTER DATABASE EnterpriseAppDB  SET RECOVERY FULL; -- Critical transaction trail requirement
GO

-- Prepare complete initial full and differential log recovery file loops
BACKUP DATABASE EnterpriseAppDB  TO DISK = '/var/opt/mssql/backup/EnterpriseAppDB.bak' WITH COMPRESSION, STATS = 30;
BACKUP LOG EnterpriseAppDB  TO DISK = '/var/opt/mssql/backup/EnterpriseAppDB.trn' WITH COMPRESSION, STATS = 30;
GO

-- Inject workspace parameters into active replication queues
ALTER AVAILABILITY GROUP [ptag] ADD DATABASE [EnterpriseAppDB];
GO

-- ========================================================================
-- AUTOMATED STORAGE RESTORATION ASSIGNMENTS
-- Run on Secondary Instance Query Profiles to confirm ingestion streams:
-- ========================================================================
/*
ALTER AVAILABILITY GROUP [ptag] GRANT CREATE ANY DATABASE;
GO
*/
