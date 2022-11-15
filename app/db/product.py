import app.db.database as db
import json
import os
database = db.redis
# product_collection = database.get_collection("products_collection")


def load_from_db(pid, market, org_id):
    pid2 = f"{org_id}_{market}_{pid}"
    db_obj = database.get(pid2)  # get the pid from database
    if db_obj is None:
        return None
    json_data = json.loads(db_obj.encode('utf-8'))
    return json_data


def load_from_db_2(market, org_id):
    market2 = f"{org_id}_{market}"  # get the market from database
    db_obj_2 = database.get(market2)
    if db_obj_2 is None:
        return None
    json_data = json.loads(db_obj_2.encode('utf-8'))
    return json_data
