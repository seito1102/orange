

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

variable "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  type        = list(string)
}

variable "certificate_arn" {
  description = "HTTPS用のACM証明書ARN"
  type        = string
}