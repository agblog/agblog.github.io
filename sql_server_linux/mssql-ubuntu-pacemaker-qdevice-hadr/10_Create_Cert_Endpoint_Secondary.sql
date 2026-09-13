USE [master];
GO

-- Create matching database instance engine master encryption key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterCertPass456!';
GO

-- Establish explicit node validation certificate token container
CREATE CERTIFICATE [db2_had_cert]
WITH SUBJECT = 'DB2 HA Routing Authentication Container Token',
START_DATE = '2026-01-01', EXPIRY_DATE = '2036-01-01';
GO

-- Export public key component binary file segments
BACKUP CERTIFICATE [db2_had_cert]
TO FILE = '/var/opt/mssql/data/db2_had_cert.cer';
GO

-- Construct secondary node mirror network tracking channel
CREATE ENDPOINT [Hadr_endpoint]
    AS TCP (LISTENER_PORT = 5022)
    FOR DATA_MIRRORING (
        ROLE = ALL,
        AUTHENTICATION = CERTIFICATE [db2_had_cert],
        ENCRYPTION = REQUIRED ALGORITHM AES
    );
GO

ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;
GO
