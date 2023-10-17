from fastapi import HTTPException
from config import config
from sshtunnel import SSHTunnelForwarder
import pymysql
import random
import shlex  
from subprocess import Popen, PIPE, STDOUT

# inspired by this thread: https://stackoverflow.com/a/14054961
def get_simple_cmd_output(cmd, stderr=STDOUT):
    args = shlex.split(cmd)
    return Popen(args, stdout=PIPE, stderr=stderr).communicate()[0].decode()

def get_ping_time(host):
    host = host.split(':')[0]
    cmd = f"fping {host} -C 1 -q"
    res = [float(x) for x in get_simple_cmd_output(cmd).strip().split(':')[-1].split() if x != '-']
    if len(res) > 0:
        return sum(res) / len(res)
    else:
        return 999999


def fastest_res_node():
    response_times = [get_ping_time(node) for node  in config.nodes_ips.values()]
    fastest_node_idx =  min(range(len(response_times)), key=response_times.__getitem__)
    return list(config.nodes_ips.values())[fastest_node_idx]

# Method to set the node to query (depending on the mode the user requested)
def set_chosen_node(mode:str) -> None :
    if not mode or mode == 'direct-hit':
        config.chosen_node = config.nodes_ips['master']
    elif mode == 'random':
        config.chosen_node = random.choice(list(config.nodes_ips.values()))
    elif mode == 'custom':
        config.chosen_node= fastest_res_node()

# Method to query the cluster
# Using SSHTunnelForwarder to access slaves nodes through the master node since they don't have MySQL client
def execute_command(command: str, mode: str):
    if not mode or mode not in config.modes:
        raise HTTPException(status_code=400, detail= 'Invalid mode')
    else:
        set_chosen_node(mode)
    with SSHTunnelForwarder(
        config.chosen_node,
        ssh_username="ubuntu",
        ssh_pkey=config.ssh_pkey,
        remote_bind_address=(config.nodes_ips['master'], 3306)
    ):
        conn= pymysql.connect(
            host=config.nodes_ips['master'],
            user= config.user,
            password=config.password,
            database=config.db_name
        )
        try:
            cursor = conn.cursor()
            cursor.execute(command)
            conn.commit()
            res = cursor.fetchall()
            return res
        except pymysql.MySQLError as e:        
            conn.rollback()
            raise HTTPException(status_code=400, detail="Error {!r} from database: {}".format(e.args[0], e.args[1]))
        finally: 
            conn.close()



