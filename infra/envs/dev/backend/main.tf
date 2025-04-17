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
  target_group_arn      = module.alb.target_group1.arn
}

module "codedeploy" {
  source  = "../../../modules/codedeploy"
  project = var.project
  env     = "dev"
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
  prod_traffic_route_listener_arn = module.alb.listener_arn
  test_traffic_route_listener_arn = module.alb.test_listener_arn
  target_group1_name = module.alb.target_group1.name
  target_group2_name = module.alb.target_group2.name
}
