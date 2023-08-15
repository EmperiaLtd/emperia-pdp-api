from fastapi import APIRouter, HTTPException, status

from app.db.product import (
    connect_and_load_from_db,
    get_markets_by_org_id,
    load_pattern_from_db,
    validate_env,
)

router = APIRouter()


@router.get(
    "/{env}/{org_id}/{market}/{p_name}", response_description="Product data retrieved"
)
async def get_product_data(env, p_name, market, org_id):
    p_name = p_name.lower()
    validate_env(env)
    product = connect_and_load_from_db(org_id, market, p_name, env)
    if product:
        return {
            "data": product,
            "status": 200,
            "message": "Products data retrieved successfully",
        }
    else:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Product doesn't exist."
        )


@router.get("/{env}/{org_id}/{market}", response_description="Products retrieved")
async def get_products(env, market, org_id):
    validate_env(env)
    solid = f"{org_id}_{market}*"
    products = load_pattern_from_db(solid, org_id, env)
    if products:
        return {
            "data": products,
            "status": 200,
            "message": "Products data retrieved successfully",
        }
    return {"data": products, "status": 200, "message": "Empty list returned"}


@router.get("/{org_id}", response_description="Market data retrieved")
async def get_market(org_id):
    markets = get_markets_by_org_id(org_id)
    if markets:
        return {
            "data": markets,
            "status": 200,
            "message": "Market data retrieved successfully",
        }
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND, detail="Market doesn't exist."
    )
