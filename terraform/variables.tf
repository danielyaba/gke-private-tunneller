variable "labels" {
  type = map
  description = "The labels."
  default = {}
}

variable "project_id" {
  type = string
  description = "The project Id."
}

variable "region" {
  type = string
  description = "The region."
}

variable "service_account" {
  type = string
  description = "The service account who has access to GKE."
}

variable "subnet_id" {
  type = string
  description = "The subnet Id."
}

variable "tags" {
  type = list
  description = "The tags."
  default = []
}

variable "vpc_id" {
  type = string
  description = "The VPC Id."
}