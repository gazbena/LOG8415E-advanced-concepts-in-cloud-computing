# API Rest app for the proxy

App created using FastAPI. The API uses the sakila database and queries MySQL cluster.
Three modes are available:
    - "direct-hit" : incoming requests are directly forwarded to MySQL master node and there will be no logic to distribute data
    - "random" : randomly selects a node on MySQL cluster and forwards the request to it
    - "custom" : measures the ping time of all the servers and forward the message to the one with less response time

## Usage

- To get the list of actors in Sakila database:
```bash
$ GET <proxy public IP>:8000/actors?mode=<mode-you-want-to-use>
```
- To post raw queries to the database:
```bash
$ POST <proxy public IP>:8000/query?mode=<mode-you-want-to-use>
```
The JSON should have this structure:
```bash
{
    "query": "<the query>"
}
```
