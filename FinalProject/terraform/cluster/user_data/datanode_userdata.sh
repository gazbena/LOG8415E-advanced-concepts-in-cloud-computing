#!/bin/bash

# Highly inspired by this article: 
# https://www.digitalocean.com/community/tutorials/how-to-create-a-multi-node-mysql-cluster-on-ubuntu-18-04

# Fetch the appropriate .deb installer file from the official MySQL
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Install package dependencies and data node binaries
sudo apt-get update && sudo apt-get install libclass-methodmaker-perl
sudo dpkg -i mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb
rm mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Create configuration file
sudo tee -a nano /etc/my.cnf << 'EOF'
[mysql_cluster]
ndb-connectstring=${manager_private_ip}
EOF

# Create data directory
sudo mkdir -p /usr/local/mysql/data

# Edit the systemd Unit file,instructing systemd on how to start, stop and restart the ndbd process
sudo tee -a nano /etc/systemd/system/ndbd.service << 'EOF'
[Unit]
Description=MySQL NDB Data Node Daemon
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndbd
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable ndbd
sudo systemctl start ndbd


