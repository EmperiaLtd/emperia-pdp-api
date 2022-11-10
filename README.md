# emperia-pdp-api

The backend REST API for apollo artemis product lines

## License


## Getting Started

### Setup
1. Set up a Unix environment (if you are on Windows, set up WSL 2).
2. [Install Python, pip, and venv.](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/)
3. Upgrade `pip` to make sure you have the latest version: `pip install --upgrade pip`
4. Set up virtual environment: `python3 -m venv env`
5. Copy contents of `EmperiaPDPAPI_ENV` on LastPass to `devenv.sh` file.

### Launch

Use this command to launch the server on `localhost:8000`:

```sh
source ./env/bin/activate; pip install -r requirements.txt; source ./devenv.sh; uvicorn app.main:app --reload
```

### Deployment

For AWS deployment using terraform

```
cd terraform/app-deploy
terraform init
terraform plan
terraform apply -auto-approve

```

### Setup local server

- Clone this repo
- Switch to development branch
- Go to cloned repo’s root folder and locate requirements.txt
- Install all dependencies from the `requirements.txt` using this command
- `pip install -r requirements.txt`
- Locate `devenv.sh`, this contains access keys, secrets and urls
- To export keys, secrets and urls to environment variables, run this command
- `. ./devenv.sh`
- To start python server, run this command
- `uvicorn app.main:app --reload`
- By default server is connected to Cluster0 - Development mongodb
- You can check if it is running properly or not by running `curl localhost:8000`

- To get a list of all Artemis spaces in terminal, you can curl like this
- `curl -X GET "localhost:8000/api/space/?org_id=Engineering-9bf9ab2f-7c83-46f6-b6ab-15369bf52c46"`

- To point Unity to local server, first locate ServerInstaller.asset
- `Assets/GameAssets/_Zeus/SDK/src/IO.Swagger/_Extra/Resources/Installers/ServerInstaller.asset`
- Change the `Api Url` under `Development Config` to [`http://127.0.0.1:8000`](http://127.0.0.1:8000/)
- Now Unity is pointing to local server, and you can check the logs in terminal for all requests

