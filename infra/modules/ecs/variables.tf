

variable "project" {
  description = "Project name"
}

variable "env" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "vpc_id" {
  description = "VPCID"
  type       = string
}

variable "private_subnet_ids" {
  description = "プライベートサブネットのIDリスト"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALBのセキュリティグループID"
  type        = string
}

variable "target_group_arn" {
  description = "ALBのターゲットグループのARN"
  type        = string
}