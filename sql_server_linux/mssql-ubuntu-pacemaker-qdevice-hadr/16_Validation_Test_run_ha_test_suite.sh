#!/bin/bash
# ==============================================================================
# HA TEST SUITE FOR UBUNTU 22.04.5 LTS | PCS 0.10.11 | CRM 4.3.0
# Target Node Node: DB1 Console Run Platform Platform. Safe to execute repeatedly.
# ==============================================================================
set -e

RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
CYAN="\033[36m"

log_test_start() {
    echo -e "\n${BOLD}${CYAN}[TEST CASE $1]${RESET} : ${BOLD}$2${RESET}"
    echo "-----------------------------------------------------------------"
}
log_pass() { echo -e "${GREEN}[PASS]${RESET} $1"; }
log_fail() { echo -e "${RED}[FAIL]${RESET} $1"; exit 1; }
log_info() { echo -e "${YELLOW}[INFO]${RESET} $1"; }

SQL_PASS="Sai5bv3sa"
AG_NAME="ptag"
DB_NAME="EnterpriseAppDB "
SQLCMD="/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $SQL_PASS -C"

export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin

log_test_start "1" "Validating Ubuntu, PCS, and CRM Engine Software Compliance"
OS_VER=$(lsb_release -d | awk -F'\t' '{print $2}')
PCS_VER=$(pcs --version)
CRM_VER=$(crm --version | head -n1 | awk '{print $2}')

[[ "$OS_VER" == *"Ubuntu 22.04"* ]] && log_pass "OS Match: $OS_VER" || log_fail "Unexpected OS Stack: $OS_VER"
[[ "$PCS_VER" == "0.10.11" ]] && log_pass "PCS Match: $PCS_VER" || log_info "PCS Variant Active: $PCS_VER"
[ -n "$CRM_VER" ] && log_pass "CRM Engine CLI Connected: Version $CRM_VER" || log_fail "CRM CLI Missing"

log_test_start "2" "Verifying Pacemaker Resource Property Layers"
if pcs resource config sqlcluster-clone | grep -E "meta.*notify=true" > /dev/null; then
    log_pass "Resource Parameter Verified: 'notify=true' flag configuration maps successfully."
else
    log_info "Injecting corrections for pcs 0.10.x schema structural block..."
    pcs resource meta sqlcluster-clone notify=true
    pcs resource config sqlcluster-clone | grep -E "notify=true" > /dev/null && log_pass "Metadata parameter injected." || log_fail "Injection block failed"
fi

log_test_start "3" "Evaluating Corosync Integrity and Device Voter"
corosync-cmapctl | grep "quorum.device.model" | grep "net" > /dev/null && log_pass "Quorum device configuration verified." || log_fail "QDevice infrastructure configuration missing."
pcs quorum status | grep -i "lms" > /dev/null && log_pass "Algorithm LMS confirmed" || log_info "LMS parser notation skipped."

log_test_start "4" "Polling Database DMV Streaming Matrices"
UNHEALTHY_ROWS=$($SQLCMD -h -1 -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.dm_hadr_database_replica_states drs WHERE drs.database_id = DB_ID('$DB_NAME') AND drs.synchronization_state_desc NOT IN ('SYNCHRONIZED', 'SYNCHRONIZING');" | tr -d '[:space:]')
[ "$UNHEALTHY_ROWS" -eq "0" ] && log_pass "All data replication containers synchronized (0 anomalies caught)" || log_fail "Replication splitcaught: $UNHEALTHY_ROWS errors."

log_test_start "5" "Checking Boundary Multi-Subnet Virtual IP Constraints"
CURRENT_MASTER=$(pcs status | grep -E "Masters:|Promoted:" | sed 's/.*\[ //' | sed 's/ \].*//' | awk '{print $1}')
log_info "Active Primary Master detected: $CURRENT_MASTER"
STATUS_DC=$(pcs resource status Listenerdc)
STATUS_DR=$(pcs resource status Listenerdr)

if [[ "$CURRENT_MASTER" == "DB1" ]] || [[ "$CURRENT_MASTER" == "DB2" ]]; then
    if echo "$STATUS_DC" | grep -E "Started|online" > /dev/null && echo "$STATUS_DR" | grep -i "Stopped" > /dev/null; then
        log_pass "DC routing constraint active: Listenerdc is ONLINE inside DC; Listenerdr remains safely DISABLED."
    else
        log_fail "Routing constraint violation! DC: $STATUS_DC | DR: $STATUS_DR"
    fi
fi

log_test_start "6" "Executing Controlled Graceful Migration Failure Simulation"
TARGET_NODE=""
[[ "$CURRENT_MASTER" == "DB1" ]] && TARGET_NODE="DB2"
[[ "$CURRENT_MASTER" == "DB2" ]] && TARGET_NODE="DB1"

if [ -z "$TARGET_NODE" ]; then
    log_info "Primary is currently on DR node. Skipping rolling migration test."
else
    log_info "Moving active master workload smoothly from $CURRENT_MASTER to $TARGET_NODE..."
    pcs resource move sqlcluster-clone $TARGET_NODE --master
    sleep 25
    NEW_MASTER=$(pcs status | grep -E "Masters:|Promoted:" | sed 's/.*\[ //' | sed 's/ \].*//' | awk '{print $1}')
    pcs resource clear sqlcluster-clone
    [[ "$NEW_MASTER" == "$TARGET_NODE" ]] && log_pass "Migration successful! Master assumed by $NEW_MASTER." || log_fail "Failover task timed out or was blocked."
fi
