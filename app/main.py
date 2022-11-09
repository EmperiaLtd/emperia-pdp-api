from fastapi import FastAPI
from mangum import Mangum

# from app.config import settings
# from app.routers import (credit, exhibit, exhibit_instance, exhibition, market,
#                          market_product, product, salesforce, space, submit,
#                          subscription, virtual_experience)

app = FastAPI(title="Emperia-PDP-API",
              root_path="/")  # (title="Emperia-PDP-API",
#               root_path="/{}".format(settings.stage_name))

# app.include_router(product.router, tags=["product"], prefix="/api/product")
# app.include_router(exhibit.router, tags=["exhibit"], prefix="/api/exhibit")
# app.include_router(exhibit_instance.router, tags=[
#                    "exhibit_instance"], prefix="/api/exhibit-instance")
# app.include_router(space.router, tags=["space"], prefix="/api/space")
# app.include_router(exhibition.router, tags=[
#                    "exhibition"], prefix="/api/exhibition")
# app.include_router(subscription.router, tags=[
#                    "subscription"], prefix="/api/subscription")
# app.include_router(submit.router, tags=["submit"], prefix="/api/submit")
# app.include_router(credit.router, tags=["credit"], prefix="/webhook/credit")
# app.include_router(salesforce.router, tags=[
#                    "salesforce"], prefix="/api/salesforce")
# app.include_router(virtual_experience.router, tags=[
#                    "virtual_experience"], prefix="/api/virtual-experience")
# app.include_router(market.router, tags=["market"], prefix="/api/market")
# app.include_router(market_product.router, tags=[
#                    "market_product"], prefix="/api/market_product")


@app.get("/")
async def read_root():
    return {
        "status_code": 200,
        "message": "Hello World"}

handler = Mangum(app, api_gateway_base_path="/")
