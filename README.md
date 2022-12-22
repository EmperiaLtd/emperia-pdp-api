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
- Install all dependencies from the `requirements.txt` using this command
- `pip install -r requirements.txt`
- [Install AWS CLI] (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Configure credentials on AWS CLI using following command
- `aws configure`
- To start python server, run this command
- `uvicorn app.main:app --reload`
- By default server is connected to Redis cloud DB and its paramteres are stored in [AWS Parameter Store]https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
- You can check if it is running properly or not by running `curl localhost:8000`
