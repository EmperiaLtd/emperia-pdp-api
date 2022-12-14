import app.db.database as db
import json
import boto3
import pandas as pd
import io
database = db.redis

# product_collection = database.get_collection("Product_collection")


def market_name(org_id, market, pid):
    if market == "US" or market == "us":
        string = f"{org_id}_USA_{pid}"
    if market == "CA" or market == "ca":
        string = f"{org_id}_CA_{pid}"
    if market == "INT" or market == "int":
        string = f"{org_id}_INT_{pid}"
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
    if '.' in price and len(price.split('.')[-1]) == 1:
        price = price + '0'
    elif '.' not in price:
        price = price + '.00'
    return price


def check_csv(org_id, market, pid):
    s3 = boto3.resource(
        service_name='s3',
        region_name='eu-west-2',
        aws_access_key_id='AKIAYYHDLHOCC53EA46L',
        aws_secret_access_key='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'
    )
    if org_id == "Saxx":
        # s3_client = boto3.resource('s3')
        s3_bucket_name = 'terraform-state-emperia-pdp'
        my_bucket = s3.Bucket(s3_bucket_name)
        bucket_list = []
        for file in my_bucket.objects.filter(Prefix='users/Saxx/'):
            file_name = file.key
            if file_name.find(".csv") != -1:
                # append all csv in  the empty bucket
                bucket_list.append(file.key)
        # if sys.version_info[0] < 3:
        #     from io import StringIO # Python 3.x

        for file in bucket_list:
            df = []
            obj = s3.Object(s3_bucket_name, file)
            data = obj.get()['Body'].read()

            if file == "users/Saxx/Dev-CA.csv":
                if market == "CA":
                    df.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding='utf-8-sig'))
                    break
            if file == "users/Saxx/Dev-INT.csv":
                if market == "INT":
                    df.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding='utf-8-sig'))
                    break
            if file == "users/Saxx/Dev-USA.csv":
                if market == "US":
                    df.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding='utf-8-sig'))
                    break

        for file in df:
            Product = pd.DataFrame(data=file)
        Product_struc = Product.get([col for col in Product.columns])
        Product_2 = []
        data_table = {}
        for index, row in Product_struc.iterrows():
            if row.ID == int(pid):
                Product_2.append(row)
        Dummy_Data = []
        Dummy_List_1 = []
        Dummy_List_2 = []
        i = 0
        if len(Product_2) > 0:
            for ID, row in enumerate(Product_2):
                solid = str(Product_2[ID]["Metafield: swatch_img [string]"])
                solid_data = f"solid/{solid}"
                if pid not in data_table:
                    data_table[pid] = {
                        'name': str(
                            Product_2[0]["Title"]), 'description': str(
                            Product_2[0]["Metafield: short_description [string]"]), 'type': str(  # noqa
                            Product_2[0]["Type"]), 'tags': str(
                            Product_2[0]["Tags"]), 'URL': str(
                            Product_2[0]["URL"]), }

                # return the product when solid is present for pid in csv
                if solid_data not in data_table[pid]:
                    if solid != "nan":
                        i = i + 1
                        for ID, row in enumerate(Product_2):
                            Size_List = {
                                     str(Product_2[ID]["Option1 Value"]):
                                        {'price': stringify_price(str(Product_2[ID]["Variant Price"])), # noqa
                                        "varient_id" : roundoff_var_id(str(Product_2[ID]["Variant ID"])), # noqa
                                        'status' : str(Product_2[ID]["Status"])}}  # noqa
                            Images_List = Product_2[ID]["Image Src"]
                            Dummy_List_1.append(Size_List)
                            Dummy_List_2.append(Images_List)
                        Solid_Content = {
                            'link': solid,
                            'size': Dummy_List_1,
                            'images': Dummy_List_2
                            }
                        Dummy_Data.append(Solid_Content)
                        data_table[pid]["solid"] = Dummy_Data

                    elif solid == "nan":  # return the product when solid is is not present for the pid in csv # noqa: E501
                        if i == 0:
                            for ID, row in enumerate(Product_2):
                                Size_List = {
                                     str(        # noqa
                                        Product_2[ID]["Option1 Value"]):
                                        {'price': stringify_price(str(Product_2[ID]["Variant Price"])), # noqa
                                        "varient_id" : roundoff_var_id(str(Product_2[ID]["Variant ID"])), # noqa
                                        'status' : str(Product_2[ID]["Status"])}}  # noqa
                                Images_List = Product_2[ID]["Image Src"]
                                Dummy_List_1.append(Size_List)
                                Dummy_List_2.append(Images_List)
                            Solid_Content = {
                               'link': solid,
                               'size': Dummy_List_1,
                               'images': Dummy_List_2
                            }
                            Dummy_Data.append(Solid_Content)
                            data_table[pid]["solid"] = Dummy_Data
                            # data_table[pid]["solid"]=[link]
                        i = i + 1
            return data_table
    else:
        return None


def load_from_db(pid, market, org_id, solid):
    pid2 = solid  # f"{org_id}_{market}_{pid}"
    db_obj = database.get(pid2)  # get the pid from database
    if db_obj is None:
        product_data = check_csv(org_id, market, pid)
        return product_data
    json_data = json.loads(db_obj.encode('utf-8'))
    return json_data


def load_from_db_2(market, org_id):
    market2 = f"{org_id}_{market}"  # get the market from database
    db_obj_2 = database.get(market2)
    if db_obj_2 is None:
        return None
    json_data = json.loads(db_obj_2.encode('utf-8'))
    return json_data


def load_from_db_3(org_id):
    if org_id == "Saxx":
        market = ["CA", "INT", "US"]
        return market
