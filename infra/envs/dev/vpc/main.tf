module "vpc" {
  source           = "../../../modules/vpc"
  project     = var.project
  env         = "dev"
  region       = var.region
  azs = ["${var.region}a", "${var.region}b"]
}