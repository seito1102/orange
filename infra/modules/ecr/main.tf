# ---------------------------------------------------
# ECR
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
# ---------------------------------------------------

resource "aws_ecr_repository" "repository" {
  name                 = "${var.project}-${var.env}-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}