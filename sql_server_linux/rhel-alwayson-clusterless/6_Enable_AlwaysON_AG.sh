#!/bin/bash
# ========================================================================
# RUNBOOK STEP 6: ALWAYS ON FEATURE REGISTRATION & SUBSCRIPTION WORKAROUND
# ========================================================================

# Note: If experiencing HighAvailability RPM subscription repository failures:
# sudo subscription-manager register
# sudo subscription-manager repos --enable=rhel-9-for-x86_64-highavailability-rpms
# sudo yum install mssql-server-ha

echo "=== Activating Core High Availability Modules ==="
# Bypass mssql-server-ha entirely and directly enable Always On High Availability (HADR)
sudo /opt/mssql/bin/mssql-conf set hadr.hadrenabled 1
sudo /opt/mssql/bin/mssql-conf set sqlagent.enabled true

echo "=== Cycling Database Engine Process Parameters ==="
sudo systemctl restart mssql-server

echo "=== Validating Dynamic Configuration Outputs ==="
sudo /opt/mssql/bin/mssql-conf get hadr.hadrenabled
cat /var/opt/mssql/mssql.conf

echo "=== Opening Synchronization Ports ==="
sudo firewall-cmd --zone=public --add-port=5022/tcp --permanent
sudo firewall-cmd --reload
