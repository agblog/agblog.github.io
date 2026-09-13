-- ========================================================================
-- RUNBOOK STEP 7: SECURE CRYPTOGRAPHIC KEYS & CERTIFICATES (PRIMARY NODE)
-- Execute within terminal connection frameworks on Node 1 (rhel-node1)
-- ========================================================================

USE master;
GO

-- Create Master Key Encrypted Layouts
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'compleXpass#1';
GO

-- Create High Availability Authentication Identity Certificate
CREATE CERTIFICATE db1 
WITH SUBJECT = 'db1 certificate for Availability Group Authentication Pipelines',
EXPIRY_DATE = '21001231';
GO

-- Provision Specialized Mirroring Network Streaming Connection Endpoints
CREATE ENDPOINT mssqldbep 
STATE = STARTED 
AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
FOR DATABASE_MIRRORING (
    AUTHENTICATION = CERTIFICATE db1,
    ENCRYPTION = REQUIRED ALGORITHM AES,
    ROLE = ALL
);
GO

-- Backup Endpoint Security Signatures to Volume File Trees
BACKUP CERTIFICATE db1 TO FILE = '/var/opt/mssql/backup/agcerts/db1.cer';
GO
