variable "project" {
  description = "Project name"
}

variable "env" {
  description = "Environment (dev, stg, prd)"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "service_name" {
  description = "Service name"
  type        = string
}

variable "prod_traffic_route_listener_arn" {
  description = "prod_traffic_route_listener_arn"
  type        = string
}

variable "test_traffic_route_listener_arn" {
  description = "test_traffic_route_listener_arn"
  type        = string
}

variable "target_group1_name" {
  description = "target_group1_name"
  type        = string
}

variable "target_group2_name" {
  description = "target_group2_name"
  type        = string
}