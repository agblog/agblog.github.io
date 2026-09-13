USE [master];
GO

-- Create database engine master encryption key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterCertPass123!';
GO

-- Establish high-availability validation certificate container token
CREATE CERTIFICATE [db1_had_cert]
WITH SUBJECT = 'DB1 HA Routing Authentication Container Token',
START_DATE = '2026-01-01', EXPIRY_DATE = '2036-01-01';
GO

-- Back up the primary database validation public key certificate to a file
BACKUP CERTIFICATE [db1_had_cert]
TO FILE = '/var/opt/mssql/data/db1_had_cert.cer';
GO

-- Open mirroring endpoint connection pipeline channel
CREATE ENDPOINT [Hadr_endpoint]
    AS TCP (LISTENER_PORT = 5022)
    FOR DATA_MIRRORING (
        ROLE = ALL,
        AUTHENTICATION = CERTIFICATE [db1_had_cert],
        ENCRYPTION = REQUIRED ALGORITHM AES
    );
GO

ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;
GO
