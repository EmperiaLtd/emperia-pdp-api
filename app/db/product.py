import time

import boto3
import pandas as pd
from fastapi import HTTPException, status

import app.db.database as db


def connect_to_db(org_id: str, env: str):
    org_id = org_id.lower()
    host_key = f"/{org_id}/db/{env}/endpoint"
    password_key = f"/{org_id}/db/{env}/password"
    db_port_key = f"/{org_id}/db/{env}/port"
    credentials = getParametersFromAWS([host_key, db_port_key, password_key])
    db.connect_to_DB(credentials[0], credentials[2], credentials[1])


def dump_product_to_db(id, product, market, client):
    db.redis.json().set(f"{client}_{market}_{id}", "$", product)


def remove_product_from_db(id, market, client):
    db.redis.delete(f"{client}_{market}_{id}")


def getParametersFromAWS(keys) -> list:
    try:
        ssm_client = boto3.client(service_name="ssm")
        response = ssm_client.get_parameters(Names=keys, WithDecryption=True)
        parameter_values = list(map(lambda r: r["Value"], response["Parameters"]))
        print(parameter_values)
        return parameter_values
    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Exception in getting DB credentials from AWS {keys} " + str(e),
        )


def create_solid(org_id, market, p_key):
    if market == "US" or market == "us":
        string = f"{org_id}_US_{p_key}"
    elif market == "CA" or market == "ca":
        string = f"{org_id}_CA_{p_key}"
    elif market == "INT" or market == "int":
        string = f"{org_id}_INT_{p_key}"
    else:
        string = f"{org_id}_{market}_{p_key}"
    return string


def connect_and_load_from_db(org_id, market, p_key, env):
    sc = time.time()
    connect_to_db(org_id, env)
    ec = time.time()
    print(f"connection time{ec - sc}")
    sl = time.time()
    response = load_from_db(org_id, market, p_key)
    el = time.time()
    print(f"load time{sl - el}")
    return response


def load_from_db(org_id, market, p_key):
    solid = create_solid(org_id, market, p_key)
    print("getting solid", solid)
    db_Obj = db.redis.json().get(solid)  # f"{org_id}_{market}_{pid}"
    if db_Obj:
        return db_Obj
    else:
        return check_for_fall_back(org_id, market, p_key)


def check_for_fall_back(org_id: str, market: str, p_key: str):
    # fallback for pinko
    if org_id == "Pinko":
        data = read_csv_file("fallback_locales.csv")
        for index, row in data.iterrows():
            if (
                row.locale.lower() == market.lower()
                and row.locale.lower() != row.defaultfeedlocale.lower()
            ):
                return load_from_db(org_id, row.defaultfeedlocale.lower(), p_key)


def load_pattern_from_db(solid, org_id, env):
    connect_to_db(org_id, env)
    print("getting solid", solid)
    # using scan here instead of keys to prevent DB blocking, results are same.
    products_response = []
    for key in db.redis.scan_iter(solid, 100):
        products_response.append(db.redis.json().get(key))
    return products_response


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


def read_csv_file(path: str):
    return pd.read_csv(path, header=0)
