# LOG8415 Final Project

## Description

This project is divided into two parts:
- The first part consisted in running a MySQL Cluster on Amazon EC2 instances and benchmark it against a standalone MySQL server (also deployed on an Amazon EC2 instance). The cluster is composed of one manager node and 3 replicas (data nodes). For benchmarking, sysbench was used. Results and commands used for benchmarking are available in the ./results folder.
- The second part consisted in implementing a proxy pattern that will route requests to the cluster. Three "modes" are available:
    1. "direct-hit" : incoming requests are directly forwarded to MySQL master node and there is no logic to distribute data.
    2. "random" : randomly selects a node on MySQL cluster and forwards the request to it.
    3. "custom" : measures the ping time of all the servers and forward the message to the one with less response time.


## Usage

- To deploy the standalone, you need to run the following command:
```bash
$ ./scripts/standalone-startup.sh
```
This script will deploy the standalone on an Amazon EC2 instance (t2.micro) with Terraform. It will also create a security group and an RSA key-pair that will be available in the root folder of the terraform project (SSH into the instance if needed). The complete terraform project can be found in ./terraform/standalone. The user_data script also performs the benchmarking and puts all the results in ~/results.zip folder.

- To deploy the MySQL Cluster and the Proxy, run the following command:
```bash
$ ./scripts/cluster-startup.sh
```
This script will first deploy the cluster (project folder: ./terraform/cluster). It will then copy the generated key in the proxy configuration folder (this is necessary because the proxy needs to send requests to the data nodes and since they don't have MySQL client installed, the requests needs to get through the master node first. SSHTunnelForwarder is used to perform this and it needs the key to SSH into the master node). It will then create a config file (config.ini) for the proxy with the public IP addresses of the manager node and the data nodes. Finally, it will deploy the proxy instance (project folder: ./terraform/proxy) and output the root needed to send requests. The proxy is a Rest application developed using the FastAPI framework and is running in a Docker container. For more infomation about how to send requests to the proxy, a documentation is available in a README.md file in the ./proxy folder.

