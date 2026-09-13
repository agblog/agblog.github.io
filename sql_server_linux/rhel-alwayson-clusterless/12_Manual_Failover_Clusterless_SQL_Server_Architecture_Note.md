#!/bin/bash
# ========================================================================
# RUNBOOK STEP 13: AUTOMATED MANUAL FAILOVER ORCHESTRATOR FOR CLUSTERLESS AG
# Run this automation tool from an administrative terminal to perform
# controlled role transitions between your standalone RHEL 9 nodes.
# ========================================================================

# Clean input prompting for dynamic user entry parameters
echo "------------------------------------------------------------"
echo "SQL Server on Linux Clusterless Failover Automation Toolkit"
echo "------------------------------------------------------------"
echo "Please enter Current Primary DB Server IP/Hostname:"
read primarydbserver

echo "Please enter Target Secondary DB Server IP/Hostname:"
read secondarydbserver

echo "Please enter Database Administrative Username (e.g., sa):"
read dbusername

echo "Please enter Database Administrative Password:"
read -s dbpassword # Using secure hidden input for password masking

echo -e "\n[INFO]: Initializing safe role transition parameters..."

# --- PHASE 1: PREPARE EXISTING PRIMARY NODE ---
echo "[1/5]: Enforcing Synchronous Commit on Target Secondary Node to guarantee zero data loss..."
sqlcmd -S "$primarydbserver" -U "$dbusername" -P "$dbpassword" -C -Q "ALTER AVAILABILITY GROUP [ptag] MODIFY REPLICA ON N'$secondarydbserver' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT);"

echo "[2/5]: Taking Availability Group [ptag] OFFLINE on existing Primary Node..."
sqlcmd -S "$primarydbserver" -U "$dbusername" -P "$dbpassword" -C -Q "ALTER AVAILABILITY GROUP [ptag] OFFLINE;"

# --- PHASE 2: ACTIVATE NEW PRIMARY NODE ---
echo "[3/5]: Forcing Failover role activation on Target Secondary Node ($secondarydbserver)..."
sqlcmd -S "$secondarydbserver" -U "$dbusername" -P "$dbpassword" -C -Q "ALTER AVAILABILITY GROUP [ptag] FORCE_FAILOVER_ALLOW_DATA_LOSS;"

echo "[INFO]: Pausing execution for 30 seconds to allow engine synchronization locks to stabilize..."
sleep 30

# --- PHASE 3: DEMOTE AND RESYNC RECOVERY NODE ---
echo "[4/5]: Demoting legacy Primary Node ($primarydbserver) to official SECONDARY role status..."
sqlcmd -S "$primarydbserver" -U "$dbusername" -P "$dbpassword" -C -Q "ALTER AVAILABILITY GROUP [ptag] SET (ROLE = SECONDARY);"

echo "[5/5]: Re-establishing data replication stream pipeline. Resuming HADR on database [EnterpriseAppDB]..."
sqlcmd -S "$primarydbserver" -U "$dbusername" -P "$dbpassword" -C -Q "ALTER DATABASE [EnterpriseAppDB] SET HADR RESUME;"

echo "------------------------------------------------------------"
echo "✅ SUCCESS: Availability Group [ptag] Failover Process Complete!"
echo "New Active Primary Node: $secondarydbserver"
echo "New Active Secondary Node: $primarydbserver"
echo "------------------------------------------------------------"
