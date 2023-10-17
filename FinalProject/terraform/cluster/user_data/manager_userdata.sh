#!/bin/bash

# Highly inspired by this article: 
# https://www.digitalocean.com/community/tutorials/how-to-create-a-multi-node-mysql-cluster-on-ubuntu-18-04

# Fetch the appropriate .deb installer file from the the official MySQL Cluster to install management server
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb
rm mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb

# Create configuration file for Cluster Manager
sudo mkdir /var/lib/mysql-cluster

sudo tee -a nano /var/lib/mysql-cluster/config.ini << 'EOF'
[ndbd default]
noofreplicas=3

[ndb_mgmd]
hostname= ${manager_private_ip}
datadir=/var/lib/mysql-cluster
nodeid=1

[ndbd]
hostname=${datanode_one_private_ip}
nodeid=2
datadir=/usr/local/mysql/data

[ndbd]
hostname=${datanode_two_private_ip}
nodeid=3
datadir=/usr/local/mysql/data

[ndbd]
hostname=${datanode_three_private_ip}
nodeid=4
datadir=/usr/local/mysql/data

[mysqld]
hostname=${manager_private_ip}

EOF

# Edit the systemd Unit file,instructing systemd on how to start, stop and restart the ndb_mgmd process
sudo tee -a nano /etc/systemd/system/ndb_mgmd.service << 'EOF'
[Unit]
Description=MySQL NDB Cluster Management Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable ndb_mgmd
sudo systemctl start ndb_mgmd

# Fetch the appropriate .deb installer file from the the official MySQL to install MySQL server
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster_7.6.6-1ubuntu18.04_amd64.deb-bundle.tar

# Extract component binaries
mkdir install
tar -xvf mysql-cluster_7.6.6-1ubuntu18.04_amd64.deb-bundle.tar -C install/

# Installing dependencies
cd install
sudo apt update
sudo apt install -y libaio1 libmecab2 zip unzip
sudo dpkg -i mysql-common_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-cluster-community-client_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-client_7.6.6-1ubuntu18.04_amd64.deb

# Disable interactive mode needed to automate installation
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'

sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-cluster-community-server_7.6.6-1ubuntu18.04_amd64.deb

sudo dpkg -i mysql-cluster-community-server_7.6.6-1ubuntu18.04_amd64.deb 
sudo dpkg -i mysql-server_7.6.6-1ubuntu18.04_amd64.deb

# Creating MySQL Server configuration file
sudo tee -a nano /etc/mysql/my.cnf << 'EOF'
[mysqld]
# Options for mysqld process:
ndbcluster                      # run NDB storage engine
bind-address = 0.0.0.0

[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=${manager_private_ip} # location of management server
EOF

# Reload daemon, enable and start the service
sudo systemctl restart mysql
sudo systemctl enable mysql

# Download Sakila database
sudo mkdir -p /tmp/sakila
cd /tmp/sakila
sudo wget https://downloads.mysql.com/docs/sakila-db.zip
sudo unzip sakila-db.zip 


# Initialize MySQL users and adds the sakila database
sudo mysql --user=root --password=password << QUERY 
CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
SOURCE /tmp/sakila/sakila-db/sakila-schema.sql;
SOURCE /tmp/sakila/sakila-db/sakila-data.sql;
GRANT ALL PRIVILEGES on sakila.* TO 'user'@'localhost' WITH GRANT OPTION;
CREATE USER 'user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES on sakila.* TO 'user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
USE sakila;
SHOW FULL TABLES;
QUERY

cd ..
sudo rm -r sakila
cd ~

# Install sysbench for benchmarking
sudo apt-get install sysbench -y
