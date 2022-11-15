from fastapi import FastAPI
from mangum import Mangum
from app.config import settings
from app.router import (product)
app = FastAPI(title="emperia-pdp-API",
              root_path="/{}".format(settings.stage_name))

app.include_router(product.router, tags=["product"], prefix="/api/product")
@app.get("/")
async def read_root():
    return {
        "status_code": 200,
        "message": "Emperia PDP REST API"}

handler = Mangum(app, api_gateway_base_path="/{}".format(settings.stage_name))