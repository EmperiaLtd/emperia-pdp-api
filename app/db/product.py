import app.db.database as db
import json
import boto3
import pandas as pd
import io
database = db.redis

# product_collection = database.get_collection("products_collection")


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
                if market == "USA":
                    df.append(
                        pd.read_csv(
                            io.BytesIO(data),
                            header=0,
                            delimiter=",",
                            low_memory=False,
                            encoding='utf-8-sig'))
                    break

        for file in df:
            products = pd.DataFrame(data=file)
        products3 = products.get([col for col in products.columns])
        product2 = []
        data_table = {}
        for index, row in products3.iterrows():
            if row.ID == int(pid):
                product2.append(row)
        arr3 = []
        arr2 = []
        i = 0
        data = []
        if len(product2) > 0:
            for ID, row in enumerate(product2):
                solid = str(product2[ID]["Metafield: swatch_img [string]"])
                solid_data = f"solid/{solid}"
                if pid not in data_table:
                    data_table[pid] = {
                        'name': str(
                            product2[0]["Title"]), 'description': str(
                            product2[0]["Metafield: short_description [string]"]), 'type': str(  # noqa
                            product2[0]["Type"]), 'tags': str(
                            product2[0]["Tags"]), 'URL': str(
                            product2[0]["URL"]), }

                # return the product when solid is present for pid in csv
                if solid_data not in data_table[pid]:
                    if solid != "nan":
                        i = i + 1
                        for ID, row in enumerate(product2):
                            Size_List = {str(
                                product2[ID]["Option1 Value"]):
                                         {'price': str(product2[ID]["Variant Price"])}}  # noqa
                            Images_List = {
                                'Image': str(
                                    product2[ID]["Image Src"])}
                            if str(product2[0]["Status"]) == "Active":
                                arr2.append(Size_List)
                            arr3.append(Images_List)
                        link = {
                            'link': solid,
                            'size': arr2,
                            'images': arr3
                            
                        }
                        data.append(link)
                        data_table[pid]["solid"] = data

                    elif solid == "nan":  # return the product when solid is is not present for the pid in csv # noqa: E501
                        if i == 0:
                            for ID, row in enumerate(product2):
                                Size_List = {str(
                                    product2[ID]["Option1 Value"]):
                                            {'price': str(product2[ID]["Variant Price"])}}  # noqa
                                Images_List = {
                                    'Image': str(
                                        product2[ID]["Image Src"])}
                                if str(product2[0]["Status"]) == "Active":
                                    arr2.append(Size_List)
                                arr3.append(Images_List)
                            link = {
                               'link': solid,
                               'size': arr2,
                               'images': arr3
                            }
                            data.append(link)
                            data_table[pid]["solid"] = data
                            # data_table[pid]["solid"]=[link]
                        i = i + 1
            return data_table
    else:
        return None


def load_from_db(pid, market, org_id):
    pid2 = f"{org_id}_{market}_{pid}"
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
        market = ["CA", "INT", "USA"]
        return market
