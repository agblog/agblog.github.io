-- ========================================================================
-- RUNBOOK STEP 9: CONNECT CROSS-NODE CREDENTIAL REPLICATION HANDSHAKES
-- ========================================================================

-- SECTION A: RUN THIS BLOCK ON THE PRIMARY NODE (rhel-node1 / 192.168.20.11)
USE [MASTER];
GO
CREATE LOGIN aglogin WITH PASSWORD = 'C!axPa$$lp';
GO
CREATE USER aglogin FOR LOGIN aglogin;
GO
-- Import secondary security block mapping tracks
CREATE CERTIFICATE db2 AUTHORIZATION aglogin FROM FILE = '/var/opt/mssql/backup/agcerts/db2.cer';
GO
GRANT CONNECT ON ENDPOINT::mssqldbep TO [aglogin];
GO


-- SECTION B: RUN THIS BLOCK ON THE SECONDARY NODE (rhel-node2 / 192.168.20.12)
/*
USE [MASTER];
GO
CREATE LOGIN aglogin WITH PASSWORD = 'C!axPa$$lp';
GO
CREATE USER aglogin FOR LOGIN aglogin;
GO
-- Import primary security block mapping tracks
CREATE CERTIFICATE db1 AUTHORIZATION aglogin FROM FILE = '/var/opt/mssql/backup/agcerts/db1.cer';
GO
GRANT CONNECT ON ENDPOINT::mssqldbep TO [aglogin];
GO
*/
