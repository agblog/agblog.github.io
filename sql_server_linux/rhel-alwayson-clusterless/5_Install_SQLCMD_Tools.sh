#!/bin/bash
# ========================================================================
# RUNBOOK STEP 5: DEPLOY ADMINISTRATIVE CLIENT COMMAND UTILITIES
# ========================================================================

echo "=== Mapping Release Binary Repository Config Pools ==="
curl https://microsoft.com | sudo tee /etc/yum.repos.d/mssql-release.repo
sudo dnf clean all

echo "=== Eliminating Legacy Component Configurations to Prevent Conflicts ==="
sudo dnf remove -y mssql-tools unixODBC-utf16-devel
sudo yum remove -y mssql-tools unixODBC-utf16 unixODBC-utf16-devel

echo "=== Deploying Production Execution Toolsets & ODBC Drivers ==="
sudo yum install -y mssql-tools18 unixODBC-devel

echo "=== Cycling Updates Subsystem Indexes ==="
sudo dnf check-update
sudo dnf update -y mssql-tools18

echo "=== Interlinking Tool Binary Pathways to Profiles ==="
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

echo "=== Baseline Version Query Check ==="
sqlcmd -S localhost -U sa -C -P 'root@123' -Q "SELECT @@VERSION;"
