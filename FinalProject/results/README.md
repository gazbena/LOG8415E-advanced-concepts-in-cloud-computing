# Sysbench benchmark

The following command have been used for benchmarking the cluster and the standalone :

## Cluster
Read-write:
```bash
sudo sysbench oltp_read_write \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-password=password \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         prepare

sudo sysbench oltp_read_write \
              --db-driver=mysql \
              --mysql-user=root \
              --mysql-password=password \
              --mysql-db=sakila \
              --tables=4 \
              --table-size=10000 \
              --threads=6 \
              --time=60 \
              run > results/read_write_results.log

sudo sysbench oltp_read_write \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-password=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup
```
Read only:
```bash
sudo sysbench oltp_read_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-password=password \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         prepare

sudo sysbench oltp_read_only \
              --db-driver=mysql \
              --mysql-user=root \
              --mysql-password=password \
              --mysql-db=sakila \
              --tables=4 \
              --table-size=10000 \
              --threads=6 \
              --time=60 \
              run > results/read_only_results.log

sudo sysbench oltp_read_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-password=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup

```
Write only:
```bash
sudo sysbench oltp_write_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-password=password \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         prepare

sudo sysbench oltp_write_only \
              --db-driver=mysql \
              --mysql-user=root \
              --mysql-password=password \
              --mysql-db=sakila \
              --tables=4 \
              --table-size=10000 \
              --threads=6 \
              --time=60 \
              run > results/write_only_results.log

sudo sysbench oltp_write_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-password=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup

```
## Standalone
Read-write:
```bash
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
              run > results/read_only_results.txt

sudo sysbench oltp_read_write \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup
```
Read only:
```bash
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
```
Write only:
```bash
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
              run > results/read_only_results.txt

sudo sysbench oltp_write_only \
         --db-driver=mysql \
         --mysql-user=root \
         --mysql-db=sakila \
         --tables=4 \
         --table-size=10000 \
         cleanup
```