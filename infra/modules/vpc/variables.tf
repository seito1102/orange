

variable "project" {
  description = "Project name"
}

variable "env" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "azs" {
  description = "Availability Zones for the region"
  type        = list(string)
}