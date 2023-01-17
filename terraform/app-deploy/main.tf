module "us-east-1" {
  source = "./modules"
  providers = {
    aws = aws.us-east-1
  }
}
module "eu-west-2" {
  source = "./modules"
  providers = {
    aws = aws
  }
}
