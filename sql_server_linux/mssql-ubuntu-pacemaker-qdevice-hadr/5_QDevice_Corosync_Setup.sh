#!/bin/bash
# ==============================================================================
# COROSYNC TOPOLOGY PROVISIONING & EXTERNAL QDEVICE NET WITNESS DEPLOYMENT
# Run This Script ONLY on Node: DB1 Primary Deployment Console
# ==============================================================================
set -e

CLUSTER_NAME="sqlcluster"
HACLUSTER_PASS="HaClusC0mpleXpa$$"
QDEV_IP="20.20.20.178"

echo "--> Authenticating secure cross-node handshake layers..."
sudo pcs host auth DB1 DB2 DR-DB1 "$QDEV_IP" -u hacluster -p "$HACLUSTER_PASS"

echo "--> Generating Corosync dual-ring routing mapping files..."
sudo pcs cluster setup "$CLUSTER_NAME" DB1 addr=192.168.1.1 DB2 addr=192.168.1.2 DR-DB1 addr=172.30.1.1 --force

echo "--> Igniting cluster automation engine states..."
sudo pcs cluster enable --all
sudo pcs cluster start --all

echo "--> Allowing 20 seconds for messaging ring convergence..."
sleep 20

echo "--> Configuring baseline environment properties flags..."
sudo pcs property set stonith-enabled=false
sudo pcs property set no-quorum-policy=stop
sudo pcs property set symmetric-cluster=true
sudo pcs resource defaults update resource-stickiness=10000

echo "--> Binding LMS Net Voter Witness device over custom Port 5403..."
sudo pcs quorum device add model net algorithm=lms host="$QDEV_IP" port=5403 --skip-offline

echo "--> Validating cluster quorum health layout status:"
sudo pcs quorum status
