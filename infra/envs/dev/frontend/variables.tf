variable "project" {
  description = "Project name"
}

variable "region" {
  description = "region"
  default     = "us-west-2"
}

variable "frontend_bucket_name" {
  description = "Vueアプリ用のS3バケット名"
  type        = string
  default = "orange-dev-frontend"
}

variable "log_bucket_name" {
  description = "CloudFrontログ用のS3バケット名"
  type        = string
  default = "orange-dev-frontend-log"
}

variable "domain_names" {
  description = "CloudFrontに紐づけるドメイン名（例: example.com）"
  type        = list(string)
  default = [ "seito.blog" ]
}