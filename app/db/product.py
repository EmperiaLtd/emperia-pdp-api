import json

import boto3
from fastapi import HTTPException, status

import app.db.database as db


def connect_to_db(org_id: str, env: str):
    org_id = org_id.lower()
    host = getParameterFromAWS(f"/{org_id}/db/{env}/endpoint")
    password = getParameterFromAWS(f"/{org_id}/db/{env}/password")
    db_port = getParameterFromAWS(f"/{org_id}/db/{env}/port")
    db.connect_to_DB(host, db_port, password)


def dump_product_to_db(id, product, market, client):
    product = json.dumps(product)
    db.redis.set(f"{client}_{market}_{id}", product)


def remove_product_from_db(id, market, client):
    db.redis.delete(f"{client}_{market}_{id}")


def getParameterFromAWS(key: str) -> str:
    # db credentials parameter format must be like this {org_id}/db/{env}/endpoint
    try:
        ssm_client = boto3.client(service_name="ssm")
        return ssm_client.get_parameter(Name=key, WithDecryption=True)["Parameter"][
            "Value"
        ]  # noqa
    except Exception as e:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"Exception in getting DB credentials from AWS {key} " + str(e),
        )


def create_solid(org_id, market, pid):
    if market == "US" or market == "us":
        string = f"{org_id}_US_{pid}"
    elif market == "CA" or market == "ca":
        string = f"{org_id}_CA_{pid}"
    elif market == "INT" or market == "int":
        string = f"{org_id}_INT_{pid}"
    else:
        string = f"{org_id}_{market}_{pid}"
    return string


def load_from_db(solid, org_id, env):
    connect_to_db(org_id, env)
    print("getting solid", solid)
    db_Obj = db.redis.get(solid)  # f"{org_id}_{market}_{pid}"
    if db_Obj:
        json_data = json.loads(db_Obj.encode("utf-8"))
        return json_data


def get_markets_by_org_id(org_id):
    if org_id == "Saxx":
        market = ["CA", "INT", "US"]
        return market


def validate_env(env: str):
    if env != "dev" and env != "prod":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Please provide a valid environment 'dev' or 'prod'",
        )
