-- ========================================================================
-- RUNBOOK STEP 10: STANDALONE AVAILABILITY GROUP DEPLOYMENT CONFIGURATION
-- ========================================================================

-- Execute on Primary Replica Engine Instance:
USE master;
GO

CREATE AVAILABILITY GROUP [ptag]
WITH (CLUSTER_TYPE = NONE) -- Creating Clusterless Session Profiles Natively
FOR REPLICA ON
N'rhel-node1' WITH (
    ENDPOINT_URL = N'tcp://192.168.20.11:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, -- Near zero-data loss recovery constraints
    FAILOVER_MODE = Manual,
    SEEDING_MODE = Automatic
),
N'rhel-node2' WITH (
    ENDPOINT_URL = N'tcp://192.168.20.12:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    FAILOVER_MODE = Manual,
    SEEDING_MODE = Automatic
);
GO

-- ========================================================================
-- SECONDARY REPLICA JOINING PROCESS PROCEDURES
-- Execute on Secondary Replica Engine Instance to attach replication loops:
-- ========================================================================
/*
ALTER AVAILABILITY GROUP [ptag] JOIN WITH (CLUSTER_TYPE = NONE);
GO
*/
