from pydantic import BaseSettings


class Settings(BaseSettings):
    env_aws_access_key: str = "xxx"
    env_aws_secret_access_key: str = "xxx"
    aws_region: str = "eu-west-2"
    stage_name: str = "dev"
    s3_bucket_name: str = "exhibitionbuilder"


settings = Settings()
