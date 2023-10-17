from configparser import ConfigParser
from fastapi import FastAPI
from routers import router_actors, router_sql_query
import paramiko
from config import config

app = FastAPI(title='Proxy')
app.include_router(router_actors)
app.include_router(router_sql_query)

# Getting hosts public IPs and from config file and getting RSA private key to connect to hosts on bootstrap
@app.on_event("startup")
async def startup():
    conf_object = ConfigParser()
    conf_object.read(".conf/config.ini")
    public_ips = conf_object["IPADDRESSES"]
    for key in config.nodes_ips.keys():
        config.nodes_ips[key] = public_ips[key]
    config.chosen_node = config.nodes_ips['master']
    config.ssh_pkey = paramiko.RSAKey.from_private_key_file(".conf/cluster-keypair.pem")
