variable "vpc_id" {
  type = string
  description = "The VPC Id."
}

variable "subnet_id" {
  type = string
  description = "The subnet Id."
}

variable "region" {
  type = string
  description = "The region."
}

variable "labels" {
  type = map
  description = "The labels."
  default = {}
}
variable "tags" {
  type = list
  description = "The tags."
  default = []
}
