#!/bin/bash
# ==============================================================================
# ALWAYSON DATABASE AUTO-HEALING & DEEP MULTI-STAGE REPAIR ORCHESTRATOR
# Targets: DB1, DB2, DR-DB1 | Built for Ubuntu 22.04 LTS Matrix
# ==============================================================================
set -e

SQL_PASS="Sai5bv3sa"
USER_PASS="EnterpriseAppDB @12345"
DB_NAME="EnterpriseAppDB "
AG_NAME="ptag"
SERVERS=("DB1" "DB2" "DR-DB1")

declare -A SERVER_IPS
SERVER_IPS=( ["DB1"]="192.168.1.1" ["DB2"]="192.168.1.2" ["DR-DB1"]="172.30.1.1" )

export PATH=$PATH:/opt/mssql-tools18/bin

echo "--> Pinpointing the current functional Primary replica instance..."
CURRENT_PRIMARY=""
for srv in "${SERVERS[@]}"; do
    TARGET_IP=${SERVER_IPS[$srv]}
    IS_PRIMARY=$(sqlcmd -S "$TARGET_IP" -U sa -P "$SQL_PASS" -C -h -1 -Q "SET NOCOUNT ON; SELECT OBJECT_ID('sys.dm_hadr_availability_replica_states')" | tr -d '[:space:]' || echo "0")
    if [ "$IS_PRIMARY" != "0" ] && [ -n "$IS_PRIMARY" ]; then
        ROLE_CHECK=$(sqlcmd -S "$TARGET_IP" -U sa -P "$SQL_PASS" -C -h -1 -Q "SET NOCOUNT ON; SELECT role_desc FROM sys.dm_hadr_availability_replica_states WHERE is_local = 1;" | tr -d '[:space:]' || echo "")
        if [ "$ROLE_CHECK" = "PRIMARY" ]; then
            CURRENT_PRIMARY="$TARGET_IP"
            echo "--> Active Primary detected at endpoint: $srv ($TARGET_IP)"
            break
        fi
    fi
done

if [ -z "$CURRENT_PRIMARY" ]; then
    echo "[!] Error: No active Primary node found. Cluster is in split or isolated state."
    exit 1
fi

for server in "${SERVERS[@]}"; do
    echo -e "\n================================================================="
    echo " Checking Sync Health on: $server "
    echo "================================================================="
    TARGET_ENDPOINT=${SERVER_IPS[$server]}

    check_sync_status() {
        NOT_SYNC_COUNT=$(sqlcmd -S "$TARGET_ENDPOINT" -U sa -P "$SQL_PASS" -C -h -1 -Q "SET NOCOUNT ON; IF OBJECT_ID('sys.dm_hadr_database_replica_states') IS NOT NULL BEGIN SELECT COUNT(*) FROM sys.dm_hadr_database_replica_states drs WHERE drs.database_id = DB_ID('$DB_NAME') AND drs.is_local = 1 AND drs.synchronization_state_desc = 'NOT SYNCHRONIZING'; END ELSE SELECT 0;" | tr -d '[:space:]' || echo "1")
        if [ "$NOT_SYNC_COUNT" -gt 0 ]; then return 1; else return 0; fi
    }

    run_sql_query() { sqlcmd -S "$TARGET_ENDPOINT" -U sa -P "$SQL_PASS" -C -Q "$1" 2>/dev/null || true; }

    if ! check_sync_status; then
        echo "[!] $server reports 'NOT SYNCHRONIZING' status anomaly."
        
        echo "--> [Stage 1] Issuing HADR RESUME instruction to $server layout..."
        run_sql_query "ALTER DATABASE [$DB_NAME] SET HADR RESUME;"
        sleep 10
        if check_sync_status; then echo "[+] $server recovered cleanly in Stage 1."; continue; fi

        echo "[!] Stage 1 failed. Trying Stage 2: Cycle Suspend and Resume..."
        run_sql_query "ALTER DATABASE [$DB_NAME] SET HADR SUSPEND;"
        sleep 2
        run_sql_query "ALTER DATABASE [$DB_NAME] SET HADR RESUME;"
        sleep 10
        if check_sync_status; then echo "[+] $server recovered cleanly in Stage 2."; continue; fi

        echo "[!] Stage 2 failed. Trying Stage 3: Restarting mssql-server service layer..."
        if [ "$server" = "DB1" ]; then sudo systemctl restart mssql-server; else sshpass -p "$USER_PASS" ssh -o StrictHostKeyChecking=no -t anurag@$TARGET_ENDPOINT "echo '$USER_PASS' | sudo -S systemctl restart mssql-server"; fi
        sleep 20
        if check_sync_status; then echo "[+] $server recovered cleanly in Stage 3."; continue; fi

        echo "[!] Hard structural block caught. Trying Stage 4: Wiping storage cache container and executing clean Automatic Seeding..."
        run_sql_query "ALTER DATABASE [$DB_NAME] SET HADR SUSPEND;"
        run_sql_query "ALTER DATABASE [$DB_NAME] SET HADR OFF;"
        run_sql_query "IF EXISTS (SELECT name FROM sys.databases WHERE name = '$DB_NAME') BEGIN ALTER DATABASE [$DB_NAME] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$DB_NAME]; END"
        run_sql_query "ALTER AVAILABILITY GROUP [$AG_NAME] GRANT CREATE ANY DATABASE;"
        
        sqlcmd -S "$CURRENT_PRIMARY" -U sa -P "$SQL_PASS" -C -Q "ALTER AVAILABILITY GROUP [$AG_NAME] MODIFY REPLICA ON N'$server' WITH (SEEDING_MODE = MANUAL);"
        sleep 2
        sqlcmd -S "$CURRENT_PRIMARY" -U sa -P "$SQL_PASS" -C -Q "ALTER AVAILABILITY GROUP [$AG_NAME] MODIFY REPLICA ON N'$server' WITH (SEEDING_MODE = AUTOMATIC);"
        sleep 15

        if check_sync_status; then echo "[+] Success! Stage 4 automatic seeding successfully restored $server layout state."; else echo "[FAIL] Critical: $server could not be auto-healed."; fi
    else
        echo "[+] $server is completely healthy and synchronizing."
    fi
done
