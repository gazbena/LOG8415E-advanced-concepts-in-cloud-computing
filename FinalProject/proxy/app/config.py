from pydantic import BaseConfig
from paramiko import RSAKey

class Config(BaseConfig):
    user = 'user'
    password = 'password'
    db_name = 'sakila'
    nodes_ips = {
        'master': '',
        'slave_one': '',
        'slave_two': '',
        'slave_three': ''
    }
    chosen_node: str
    ssh_pkey: RSAKey = None
    modes = ['direct-hit', 'random', 'custom']

config = Config()