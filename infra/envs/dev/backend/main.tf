module "alb" {
  source            = "../../../modules/alb"
  project           = var.project
  env               = "dev"
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  certificate_arn   = data.aws_acm_certificate.backend.arn
}

module "ecr" {
  source  = "../../../modules/ecr"
  project = var.project
  env     = "dev"
}

module "ecs" {
  source                = "../../../modules/ecs"
  project               = var.project
  env                   = "dev"
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids    = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
}