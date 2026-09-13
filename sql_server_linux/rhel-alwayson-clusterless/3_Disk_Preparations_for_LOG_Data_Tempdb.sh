#!/bin/bash
# ========================================================================
# RUNBOOK STEP 3: STORAGE DIRECTORIES MOUNT PRIMING & ENFORCED SELINUX SEPARATION
# ========================================================================

echo "=== Initializing Distinct Volume Mount Point Trees ==="
# Host db1 and db2 must have separate mount points for data and log files
# 1. sql-data
# 2. sql-tlog
# 3. sql-tempdb

sudo mkdir -p /var/opt/mssql/sql-data
sudo mkdir -p /var/opt/mssql/sql-tlog
sudo mkdir -p /var/opt/mssql/sql-tempdb
sudo mkdir -p /var/opt/mssql/backup/agcerts

echo "=== Configuring Filesystem Discretionary Access Boundaries ==="
sudo chown -R mssql:mssql /var/opt/mssql/sql-data
sudo chown -R mssql:mssql /var/opt/mssql/sql-tlog
sudo chown -R mssql:mssql /var/opt/mssql/sql-tempdb
sudo chown -R mssql:mssql /var/opt/mssql/backup

sudo chmod -R 700 /var/opt/mssql/sql-data
sudo chmod -R 700 /var/opt/mssql/sql-tlog
sudo chmod -R 700 /var/opt/mssql/sql-tempdb
sudo chmod -R 776 /var/opt/mssql/backup/agcerts

echo "=== Engineering Hardened Target Security Context Mappings via SELinux ==="
sudo semanage fcontext -a -t mssql_db_t "/var/opt/mssql/sql-data(/.*)?"
sudo semanage fcontext -a -t mssql_db_t "/var/opt/mssql/sql-tlog(/.*)?"
sudo semanage fcontext -a -t mssql_db_t "/var/opt/mssql/sql-tempdb(/.*)?"
sudo semanage fcontext -a -t mssql_db_t "/var/opt/mssql/backup/agcerts(/.*)?"
sudo semanage fcontext -a -t mssql_db_t "/var/opt/mssql/backup(/.*)?"

echo "=== Triggering Immediate Context Refreshes across Target Trees ==="
sudo restorecon -R -v /var/opt/mssql/sql-data
sudo restorecon -R -v /var/opt/mssql/sql-tlog
sudo restorecon -R -v /var/opt/mssql/sql-tempdb
sudo restorecon -R -v /var/opt/mssql/backup/agcerts
sudo restorecon -R -v /var/opt/mssql/backup
