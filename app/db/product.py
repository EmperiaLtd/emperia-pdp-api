import json
import os

import boto3

import app.db.database as db

# product_collection = database.get_collection("Product_collection")


def connect_to_db():
    host = getParameterFromAWS(os.getenv("db_host"))
    password = getParameterFromAWS(os.getenv("db_password"))
    db_port = getParameterFromAWS(os.getenv("db_port"))
    db.connect_to_DB(host, db_port, password)


def getParameterFromAWS(key: str) -> str:
    ssm_client = boto3.client(service_name="ssm")
    return ssm_client.get_parameter(Name=key, WithDecryption=True)["Parameter"][
        "Value"
    ]  # noqa


def create_solid(org_id, market, pid):
    if market == "US" or market == "us":
        return f"{org_id}_USA_{pid}"
    if market == "CA" or market == "ca":
        return f"{org_id}_UK_{pid}"
    if market == "INT" or market == "int":
        return f"{org_id}_INT_{pid}"


def load_from_db(solid):
    connect_to_db()
    print("getting solid", solid)
    db_Obj = db.redis.get(solid)  # f"{org_id}_{market}_{pid}"
    if db_Obj:
        json_data = json.loads(db_Obj.encode("utf-8"))
        return json_data


def get_markets_by_org_id(org_id):
    if org_id == "Saxx":
        market = ["CA", "INT", "US"]
        return market
