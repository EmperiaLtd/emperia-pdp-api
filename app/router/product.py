from fastapi import APIRouter, Body, status, HTTPException
from app.db.product import (
    load_from_db,
    load_from_db_2,
)

router = APIRouter()
# def ResponseModel(data, status_code, message):
#     return {
#         "data": data,
#         "status_code": status_code,
#         "message": message
#     }


@router.get("/{org_id}/{market}", response_description="Products retrieved")
async def get_products(market, org_id):
    products = load_from_db_2(market, org_id)
    if products:
        return {"data": products, "status": 200, "message":
                "Products data retrieved successfully"}
    return {"data": products, "status": 200, "message": "Empty list returned"}


@router.get("/{org_id}/{market}/{pid}",
            response_description="Product data retrieved")
async def get_product_data(pid, market, org_id):
    product = load_from_db(pid, market, org_id)
    if product:
        return {"data": product, "status": 200, "message":
                "Products data retrieved successfully"}
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail="Product doesn't exist.")
