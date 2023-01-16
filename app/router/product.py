from fastapi import APIRouter, HTTPException, status

from app.db.product import (
    load_from_db,
    load_from_db_2,
    load_from_db_3,
    market_name,
    validate_env,
)

# database = db.redis
router = APIRouter()
# def ResponseModel(data, status_code, message):
#     return {
#         "data": data,
#         "status_code": status_code,
#         "message": message
#     }


@router.get(
    "/{env}/{org_id}/{market}/{p_name}", response_description="Product data retrieved"
)
async def get_product_data(env, p_name, market, org_id):
    p_name = p_name.lower()
    solid = market_name(org_id, market, p_name)
    validate_env(env)
    product = load_from_db(env, p_name, market, org_id, solid)
    if product:
        return {
            "data": product,
            "status": 200,
            "message": "Products data retrieved successfully",
        }
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Product doesn't exist."
    )


@router.get("/{env}/{org_id}/{market}", response_description="Products retrieved")
async def get_products(env, market, org_id):
    validate_env(env)
    products = load_from_db_2(env, market, org_id)
    if products:
        return {
            "data": products,
            "status": 200,
            "message": "Products data retrieved successfully",
        }
    return {"data": products, "status": 200, "message": "Empty list returned"}


@router.get("/{org_id}", response_description="Market data retrieved")
async def get_market(org_id):
    product = load_from_db_3(org_id)
    if product:
        return {
            "data": product,
            "status": 200,
            "message": "Market data retrieved successfully",
        }
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Market doesn't exist."
    )
