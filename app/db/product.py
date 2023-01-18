import io
import json

import boto3
import pandas as pd
from fastapi import HTTPException, status

import app.db.database as db

# product_collection = database.get_collection("Product_collection")


def connect_to_db(org_id: str, env: str):
    org_id = org_id.lower
    host = getParameterFromAWS(f"/{org_id}/db/{env}/endpoint")
    password = getParameterFromAWS(f"/{org_id}/db/{env}/password")
    db_port = getParameterFromAWS(f"/{org_id}/db/{env}/port")
    db.connect_to_DB(host, db_port, password)


def getParameterFromAWS(key: str) -> str:
    # db credentials parameter format must be like this {org_id}/db/{env}/endpoint
    try:
        ssm_client = boto3.client(service_name="ssm")
        return ssm_client.get_parameter(Name=key, WithDecryption=True)["Parameter"][
            "Value"
        ]  # noqa
    except Exception:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"Exception in getting DB credentials from AWS {key}",
        )


def market_name(org_id, market, pid):
    if market == "US" or market == "us":
        string = f"{org_id}_US_{pid}"
    elif market == "CA" or market == "ca":
        string = f"{org_id}_CA_{pid}"
    elif market == "INT" or market == "int":
        string = f"{org_id}_INT_{pid}"
    else:
        string = f"{org_id}_{market}_{pid}"
    return string


def roundoff_var_id(varient_id):
    varient_id = varient_id.split(".")[0]
    return varient_id


def stringify_price(price):
    """
    Takes any number as input for price and returns it in a normalised format
    which always includes two decimal places ($0.00) for the price
    :return str:
    """
    price = str(float(price))
    if "." in price and len(price.split(".")[-1]) == 1:
        price = price + "0"
    elif "." not in price:
        price = price + ".00"
    return price


def data_frame(org_id, market, pid):

    """Function for making a data frame and apending that INTO a Empty list called DF  # noqa
    and return that list(only if org_id==Saxx else it return None"""
    s3 = boto3.resource(service_name="s3")
    if org_id == "Saxx":
        s3_bucket_name = "terraform-state-emperia-pdp"
        my_bucket = s3.Bucket(s3_bucket_name)
        bucket_list = []

        for file in my_bucket.objects.filter(Prefix="users/Saxx/"):
            file_name = file.key
            if file_name.find(".csv") != -1:
                # append all csv in  the empty bucket
                bucket_list.append(file.key)

        for file in bucket_list:
            DF = []  # Empty list for storing dataframe
            obj = s3.Object(s3_bucket_name, file)
            data = obj.get()["Body"].read()

            if file == "users/Saxx/Dev-CA.csv":
                if market == "CA":
                    DF.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding="utf-8-sig",
                        )
                    )
                    break
            if file == "users/Saxx/Dev-INT.csv":
                if market == "INT":
                    DF.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding="utf-8-sig",
                        )
                    )
                    break
            if file == "users/Saxx/Dev-USA.csv":
                if market == "US":
                    DF.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding="utf-8-sig",
                        )
                    )
                    break
        return DF
    else:
        return None


def check_csv(org_id, market, p_name):
    DF = data_frame(org_id, market, p_name)
    for file in DF:
        Product = pd.DataFrame(data=file)
    product_struc = Product.get([col for col in Product.columns])
    Product_2 = []
    data_table = {}
    for index, row in product_struc.iterrows():
        if row.Title == int(p_name):
            Product_2.append(row)
    Dummy_Data = []
    Dummy_List_1 = []
    Dummy_List_2 = []
    i = 0
    if len(Product_2) > 0:
        for ID, row in enumerate(Product_2):
            solid = str(Product_2[ID]["Metafield: swatch_img [string]"])
            solid_data = f"solid/{solid}"
            if p_name not in data_table:
                data_table[p_name] = {
                    "name": str(Product_2[0]["Title"]),
                    "description": str(
                        Product_2[0]["Metafield: short_description [string]"]
                    ),
                    "type": str(Product_2[0]["Type"]),  # noqa
                    "tags": str(Product_2[0]["Tags"]),
                    "URL": str(Product_2[0]["URL"]),
                    "handle": str(Product_2[0]["Handle"]),
                }

            # return the product when solid is present for pid in csv
            if solid_data not in data_table[p_name]:
                if solid != "nan":
                    i = i + 1
                    for ID, row in enumerate(Product_2):
                        Size_List = {
                            str(Product_2[ID]["Option1 Value"]): {
                                "price": stringify_price(
                                    str(Product_2[ID]["Variant Price"])
                                ),  # noqa
                                "variant_id": roundoff_var_id(
                                    str(Product_2[ID]["Variant ID"])
                                ),  # noqa
                                "status": str(Product_2[ID]["Status"]),
                            }
                        }  # noqa
                        Images_List = str(Product_2[ID]["Image Src"])
                        Dummy_List_1.append(Size_List)
                        Dummy_List_2.append(Images_List)
                    Solid_Content = {
                        "product_color": solid,
                        "size": Dummy_List_1,
                        "images": Dummy_List_2,
                    }
                    Dummy_Data.append(Solid_Content)
                    data_table[p_name]["solid"] = Dummy_Data

                elif (
                    solid == "nan"
                ):  # return the product when solid is is not present for the pid in csv # noqa: E501
                    if i == 0:
                        for ID, row in enumerate(Product_2):
                            Size_List = {
                                str(Product_2[ID]["Option1 Value"]): {
                                    "price": stringify_price(
                                        str(Product_2[ID]["Variant Price"])
                                    ),  # noqa
                                    "variant_id": roundoff_var_id(
                                        str(Product_2[ID]["Variant ID"])
                                    ),  # noqa
                                    "status": str(Product_2[ID]["Status"]),
                                }
                            }  # noqa
                            Images_List = str(Product_2[ID]["Image Src"])
                            Dummy_List_1.append(Size_List)
                            Dummy_List_2.append(Images_List)
                        Solid_Content = {
                            "product_color": solid,
                            "size": Dummy_List_1,
                            "images": Dummy_List_2,
                        }
                        Dummy_Data.append(Solid_Content)
                        data_table[p_name]["solid"] = Dummy_Data
                        # data_table[pid]["solid"]=[link]
                    i = i + 1
        return data_table


def load_from_db(env: str, p_name: str, market: str, org_id: str, solid: str):
    p_id_2 = solid  # f"{org_id}_{market}_{p_name}"
    connect_to_db(org_id, env)
    db_Obj = db.redis.get(p_id_2)  # get the pid from database
    if db_Obj is None:
        product_data = check_csv(org_id, market, p_name)
        product_json = json.dumps(product_data)
        db.redis.set(solid, product_json)
        return product_data
    json_data = json.loads(db_Obj.encode("utf-8"))
    return json_data


def load_from_db_2(env: str, market, org_id):
    Market_2 = f"{org_id}_{market}_*"  # get the market from database
    connect_to_db(org_id, env)
    db_Obj_2 = db.redis.get(Market_2)
    if db_Obj_2 is None:
        return None
    json_data = json.loads(db_Obj_2.encode("utf-8"))
    return json_data


def load_from_db_3(org_id):
    if org_id == "Saxx":
        market = ["CA", "INT", "US"]
        return market


def validate_env(env: str):
    if env != "dev" and env != "prod":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Please provide a valid environment 'dev' or 'prod'",
        )
