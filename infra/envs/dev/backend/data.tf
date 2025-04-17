# vpcのtfstateを読む
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "seitotest-tfstate-bucket"
    key    = "dev/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

# 証明書取得 (手動作成したACM)
data "aws_acm_certificate" "backend" {
  domain   = "api.seito.blog"
  statuses = ["ISSUED"]
}
