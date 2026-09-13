USE [master];
GO

-- Construct production target operational schema
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'EnterpriseAppDB ')
    CREATE DATABASE [EnterpriseAppDB];
GO

ALTER DATABASE [EnterpriseAppDB] SET RECOVERY FULL;
GO

-- Take standard database baseline sync backups logs markers
BACKUP DATABASE [EnterpriseAppDB] TO DISK = '/var/opt/mssql/data/EnterpriseAppDB _base_seed.bak' WITH FORMAT, INIT;
GO

-- Bind target schemas onto tracking availability group layout matrices
ALTER AVAILABILITY GROUP [ptag] ADD DATABASE [EnterpriseAppDB];
GO
