#!/bin/bash
# ========================================================================
# RUNBOOK STEP 4: KERNEL UPGRADES, WORKAROUNDS & DATABASE ENGINE PROVISIONING
# ========================================================================

echo "=== Updating Operating System Pool Layers to Resolve Dependency Drift ==="
# Updating Redhat 9.4 to 9.7/9.8 first as there's some package issues.
# The repos give packages for newer versions but documentation is mismatched.
sudo dnf clean all
sudo dnf update -y

echo "=== Registering Enterprise Database Product Package Repositories ==="
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://microsoft.com

echo "=== Resolving Enforcing Security Model Package Blockers ==="
# Workaround for: 'nothing provides selinux-policy-base >= 38.1.65-1.el9_7.1 needed by mssql-server-selinux'
# Option: Bypass the SELinux Package (Fastest & Most Common) [NOT ON PRODUCTION - PRODUCTION NEEDS ENFORCING MODE]
sudo dnf clean all
sudo dnf install -y mssql-server

echo "=== Shifting Context Enforcement Model to Permissive ==="
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

echo "=== Provisioning Local Volume Footprints & Launching Engine Setup ==="
# SQL Server installs directly into /opt/mssql, check your space parameters via df -h
sudo /opt/mssql/bin/mssql-conf setup
# Interactive Choice: Select '2' for Enterprise Developer Edition and define strong SA password

echo "=== Verifying Active System Layer Service Status ==="
systemctl status mssql-server --no-pager

echo "=== Authorizing Networking Perimeter Routing ==="
sudo firewall-cmd --zone=public --add-port=1433/tcp --permanent
sudo firewall-cmd --reload
