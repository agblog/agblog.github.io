-- ========================================================================
-- RUNBOOK STEP 8: SECURE CRYPTOGRAPHIC KEYS & CERTIFICATES (SECONDARY NODE)
-- Execute within terminal connection frameworks on Node 2 (rhel-node2)
-- ========================================================================

USE master;
GO

-- Create Matching Database Master Security Infrastructure Keys
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Complexpass#1';
GO

-- Create Secondary Identity Certificates
CREATE CERTIFICATE db2 
WITH SUBJECT = 'db2 certificate for Availability Group Authentication Pipelines',
EXPIRY_DATE = '21001231';
GO

-- Map Connection Listening Parameters to the High Availability Ports
CREATE ENDPOINT mssqldbep 
STATE = STARTED 
AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
FOR DATABASE_MIRRORING (
    AUTHENTICATION = CERTIFICATE db2,
    ENCRYPTION = REQUIRED ALGORITHM AES,
    ROLE = ALL
);
GO

-- Backup Endpoint Security Signatures for Primary Transport
BACKUP CERTIFICATE db2 TO FILE = '/var/opt/mssql/backup/agcerts/db2.cer';
GO
