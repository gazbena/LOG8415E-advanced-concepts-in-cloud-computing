from typing import Union
from fastapi import APIRouter
from pydantic import BaseModel
from pymysql import MySQLError
from database import execute_command, set_chosen_node
from config import config
import logging

logger = logging.getLogger()

router_actors = APIRouter(
    prefix="/actors",
    tags=["actors"]
)

router_sql_query = APIRouter(
    prefix="/query",
    tags=["query"]
)

class SQLQuery(BaseModel):
    query:str

@router_actors.get('/',  summary="List of actors", description= 'Returns all actors')
async def get_actors(mode: Union[str, None] = None):
    try:
        res = execute_command(command="SELECT * FROM actor", mode=mode)
        return {"actor":res,"query-mode":mode, "selected-node": config.chosen_node}
    except ValueError:
        raise

@router_actors.get('/{actor_id}', summary="List of actors", description= 'Returns an actor')
async def get_actor(actor_id: int, mode: Union[str, None] = None):
    try:
        res = execute_command(command=f"SELECT * FROM actor WHERE actor_id = {actor_id}", mode=mode)
        return {"actor":res[0],"query-mode":mode, "selected-node": config.chosen_node}
    except ValueError:
        raise

@router_sql_query.post('/')
async def post_sql_query(sql: SQLQuery, mode: Union[str, None] = None):
    try:
        res = execute_command(sql.query, mode=mode)
        return {"response": res, "query-mode": mode, "selected-node": config.chosen_node}
    except ValueError:
        raise

        


