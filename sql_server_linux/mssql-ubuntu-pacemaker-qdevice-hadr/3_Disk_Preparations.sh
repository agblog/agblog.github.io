#!/bin/bash
# ==============================================================================
# PHYSICAL STORAGE MATRIX PROVISIONING & MOUNT SEGMENTATION ORCHESTRATOR
# Targets: DB1, DB2, DR-DB1 | Filesystem Base: High-Performance Production XFS
# ==============================================================================
set -e

echo "--> Initializing target hardware storage physical device blocks..."
sudo pvcreate /dev/sdb /dev/sdc
sudo vgcreate vg_mssql /dev/sdb /dev/sdc

echo "--> Partitioning isolated high-speed execution volumes..."
sudo lvcreate -L 80G -n lv_data vg_mssql
sudo lvcreate -L 50G -n lv_log vg_mssql
sudo lvcreate -L 50G -n lv_tempdb vg_mssql

echo "--> Forcing non-lazy file system catalog formatting blocks..."
sudo mkfs.xfs -K /dev/vg_mssql/lv_data
sudo mkfs.xfs -K /dev/vg_mssql/lv_log
sudo mkfs.xfs -K /dev/vg_mssql/lv_tempdb

echo "--> Building structural runtime directories maps..."
sudo mkdir -p /var/opt/mssql/data /var/opt/mssql/log /var/opt/mssql/tempdb

echo "--> Registering device mount configuration maps to system fstab..."
cat << 'EOF' | sudo tee -a /etc/fstab
/dev/vg_mssql/lv_data    /var/opt/mssql/data    xfs    defaults,noatime,nodiratime    0 0
/dev/vg_mssql/lv_log     /var/opt/mssql/log     xfs    defaults,noatime,nodiratime    0 0
/dev/vg_mssql/lv_tempdb  /var/opt/mssql/tempdb  xfs    defaults,noatime,nodiratime    0 0
EOF

echo "--> Mounting physical partitions..."
sudo mount -a
sudo chown -R mssql:mssql /var/opt/mssql
echo "--> Storage infrastructure segmentation provisioned successfully!"
