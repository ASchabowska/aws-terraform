variable "vpc_id" {
  type = string
}

variable "vpc_subnet_id" {
  type        = string
  description = "Private Subnets for the Lambda"
}