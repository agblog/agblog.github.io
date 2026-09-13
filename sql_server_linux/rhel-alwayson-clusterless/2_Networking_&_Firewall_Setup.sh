#!/bin/bash
# ========================================================================
# RUNBOOK STEP 2: HOSTNAME SETUP, /etc/hosts AND FIREWALL LAYER CONFIG
# ========================================================================

# On each node execute hostname update:
# hostnamectl set-hostname <hostname> # db1, db2, db-backup, db-cluster

echo "=== Configuring /etc/hosts entries ==="
# Emulating direct modifications from 'vim /etc/hosts' safely
sudo tee /etc/hosts <<EOF
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
rhel-node1 192.168.20.11
rhel-node2 192.168.20.12
EOF

echo "=== Configuring firewalld persistent rule matrices ==="
sudo firewall-cmd --permanent --add-port=2224/tcp
sudo firewall-cmd --permanent --add-port=3121/tcp
sudo firewall-cmd --permanent --add-port=21064/tcp
sudo firewall-cmd --permanent --add-port=5405/udp
sudo firewall-cmd --permanent --add-port=1433/tcp # Replace with TDS endpoint
sudo firewall-cmd --permanent --add-port=5022/tcp # Replace with DATA_MIRRORING endpoint
sudo firewall-cmd --reload

echo "=== Installing validation connection engines ==="
sudo dnf install -y telnet

echo "=== Executing Network Ping Reachability Tests ==="
ping -c 3 192.168.20.11
ping -c 3 192.168.20.12
ping -c 3 rhel-node1
ping -c 3 rhel-node2

echo "========================================================================"
echo "MANUAL VERIFICATION ACTIONS REQUIRED (Cross-Node Telnet Loops):"
echo "From Node 2, run these commands to verify Node 1 is listening:"
echo "  telnet 192.168.20.11 2224"
echo "  telnet 192.168.20.11 3121"
echo "  telnet 192.168.20.11 21064"
echo "  telnet 192.168.20.11 1433"
echo "  telnet 192.168.20.11 5022"
echo ""
echo "Verify UDP cluster hearbeat port connectivity using netcat:"
echo "  nc -zvu 192.168.20.11 5405"
echo "  nc -zvu 192.168.20.12 5405"
echo "========================================================================"
