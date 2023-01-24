import json
import os
import os.path

from fastapi.testclient import TestClient

from app.db.product import connect_to_db, dump_product_to_db, remove_product_from_db
from app.main import app

client = TestClient(app)


def test_get_market_data_exists():
    org_id = "Saxx"
    expected_data = ["CA", "INT", "US"]
    expected_status_code = 200
    response = client.get(f"/api/product/{org_id}")
    print(response)
    assert response.status_code == expected_status_code
    assert response.json()["data"] == expected_data


def test_get_market_data_not_exists():
    org_id = "Levis"

    expected_status_code = 404
    expected_message = '{"detail":"Market doesn\'t exist."}'

    response = client.get(f"/api/product/{org_id}")

    assert response.status_code == expected_status_code
    assert response.text == expected_message


def test_get_product_data_exists():
    org_id = "Saxx"
    market = "INT"
    product_id = "121212121"
    env = "dev"
    dirpath = os.path.dirname(__file__)
    expected_data_file = open(
        os.path.join(dirpath, "resources", "expected_response_data.json")
    )
    expected_status_code = 200
    expected_data = json.load(expected_data_file)
    connect_to_db(org_id, env)
    dump_product_to_db(product_id, expected_data, market, org_id)

    response = client.get(f"api/product/{env}/{org_id}/{market}/{product_id}")

    assert response.status_code == expected_status_code
    assert response.json()["data"] == expected_data

    remove_product_from_db(product_id, market, org_id)


def test_get_product_data_not_exists():
    org_id = "Saxx"
    market = "US"
    product_id = "6743322198107"  # Invalid Product Id
    env = "dev"
    expected_status_code = 404
    expected_message = '{"detail":"Product doesn\'t exist."}'

    response = client.get(f"api/product/{env}/{org_id}/{market}/{product_id}")

    assert response.status_code == expected_status_code
    assert response.text == expected_message


def test_get_product_data_invalid_market():
    org_id = "Saxx"
    market = "SP"  # Invalid Market
    product_id = "6775348068433"
    env = "dev"

    expected_status_code = 404
    expected_message = '{"detail":"Product doesn\'t exist."}'

    response = client.get(f"api/product/{env}/{org_id}/{market}/{product_id}")

    assert response.status_code == expected_status_code
    assert response.text == expected_message
