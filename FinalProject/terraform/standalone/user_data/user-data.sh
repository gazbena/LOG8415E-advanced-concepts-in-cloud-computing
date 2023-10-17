#!/bin/bash

# Install mysql-server and dependencies
sudo apt-get update
sudo apt-get install mysql-server -y
sudo apt-get install unzip zip

sudo mkdir -p /tmp/sakila
cd /tmp/sakila
sudo wget https://downloads.mysql.com/docs/sakila-db.zip
sudo unzip sakila-db.zip 


# Add the sakila database
sudo mysql -u root -e "SOURCE /tmp/sakila/sakila-db/sakila-schema.sql;"
sudo mysql -u root -e "SOURCE /tmp/sakila/sakila-db/sakila-data.sql;"

cd ..
sudo rm -r sakila
cd ~



# install sysbench and run benchmark
sudo apt-get install sysbench -y

mkdir results

echo "performing read-write benchmarking"
# read-write
sudo sysbench oltp_read_write \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         prepare

sudo sysbench oltp_read_write \
              --db-driver=mysql \
              --mysql-user=root \
              --mysql-db=sakila \
              --tables=4 \
              --table-size=10000 \
              --threads=6 \
              --time=60 \
              run > results/read_write_results.txt

sudo sysbench oltp_read_write \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup

echo "performing write benchmarking"

# write-only
sudo sysbench oltp_write_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         prepare

sudo sysbench oltp_write_only \
              --db-driver=mysql \
              --mysql-user=root \
              --mysql-db=sakila \
              --tables=4 \
              --table-size=10000 \
              --threads=6 \
              --time=60 \
              run > results/write_only_results.txt

sudo sysbench oltp_write_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup

echo "performing read benchmarking"

# read-only
sudo sysbench oltp_read_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         prepare

sudo sysbench oltp_read_only \
              --db-driver=mysql \
              --mysql-user=root \
              --mysql-db=sakila \
              --tables=4 \
              --table-size=10000 \
              --threads=6 \
              --time=60 \
              run > results/read_only_results.txt

sudo sysbench oltp_read_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup

zip -r /tmp/results.zip results