# emperia-pdp-api

The backend REST API for apollo artemis product lines

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
- Switch to main branch
- Go to cloned repo’s root folder and locate requirements.txt
- Install all dev dependencies from the `dev_requirements.txt` using this command
- `pip install -r dev_requirements.txt`
- [Install AWS CLI] (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Configure credentials on AWS CLI using following command
- `aws configure`
- To start python server, run this command
- `uvicorn app.main:app --reload`
- By default server is connected to Redis cloud DB and its paramteres are stored in [AWS Parameter Store]https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
- You can check if it is running properly or not by running `curl localhost:8000`

### Setup pre-commit hook
Run this command to setup git pre-commit hook for development
`pre-commit install`

### Testing
- All API tests are written in test_main.py
- To run tests simply run these commands
- `pip install -r requirements.txt`
- `pytest`
