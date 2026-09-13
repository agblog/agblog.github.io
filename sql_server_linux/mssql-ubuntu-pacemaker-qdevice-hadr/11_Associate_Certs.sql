USE [master];
GO

-- Establish dedicated endpoint tracking instance system logins
CREATE LOGIN [db1_login] WITH PASSWORD = 'NodeAuthLoginPass1!';
CREATE LOGIN [db2_login] WITH PASSWORD = 'NodeAuthLoginPass2!';
CREATE LOGIN [drdb1_login] WITH PASSWORD = 'NodeAuthLoginPass3!';
GO

-- Map users onto system framework parameters
CREATE USER [db1_user] FOR LOGIN [db1_login];
CREATE USER [db2_user] FOR LOGIN [db2_login];
CREATE USER [drdb1_user] FOR LOGIN [drdb1_login];
GO

-- Consume external copied binary data key files into security layer maps
CREATE CERTIFICATE [db1_had_cert] AUTHORIZATION [db1_user] FROM FILE = '/var/opt/mssql/data/db1_had_cert.cer';
CREATE CERTIFICATE [db2_had_cert] AUTHORIZATION [db2_user] FROM FILE = '/var/opt/mssql/data/db2_had_cert.cer';
CREATE CERTIFICATE [drdb1_had_cert] AUTHORIZATION [drdb1_user] FROM FILE = '/var/opt/mssql/data/drdb1_had_cert.cer';
GO

-- Allocate explicit connectivity maps on mirroring endpoints channel layers
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [db1_login];
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [db2_login];
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [drdb1_login];
GO
