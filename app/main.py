from fastapi import FastAPI
from mangum import Mangum


app = FastAPI(title="Emperia-PDP-API",
              root_path="/")


@app.get("/")
async def read_root():
    return {
        "status_code": 200,
        "message": "Hello World"}

handler = Mangum(app, api_gateway_base_path="/")
