provider "aws" {
  region  = var.region
  profile = "default"
}


# s3 bucket for terraform state

resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "terraform-state-emperia-pdp"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

  billing_mode = "PAY_PER_REQUEST"
}
