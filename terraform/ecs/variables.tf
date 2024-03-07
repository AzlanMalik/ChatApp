variable "ecs-cloudwatch" {
  default = "chatapp-ecs-cloudwatch-logs"
}

variable "app-name" {
  default = "chatapp"
}


variable "aws-region" {
  default = "me-central-1"
}

variable "environment" {
  default = "chatapp"
}

variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block of the vpc"
}

variable "public-subnets-cidr" {
  type        = list(any)
  default     = ["10.0.0.0/20", "10.0.128.0/20"]
  description = "CIDR block for Public Subnet"
}

variable "private-subnets-cidr" {
  type        = list(any)
  default     = ["10.0.16.0/20", "10.0.144.0/20"]
  description = "CIDR block for Private Subnet"
}


/* -------------------------------------------------------------------------- */
/*                           APP - SERVICE VARIABLES                          */
/* -------------------------------------------------------------------------- */
variable "app-cpu" {
  default= 512
}

variable "app-memory" {
  default = 1024
}

variable "app-max-capacity" {
  default = 2
}

variable "app-min-capacity" {
  default = 2
}

/* -------------------------------------------------------------------------- */
/*                           DB - SERVICE VARIABLES                           */
/* -------------------------------------------------------------------------- */
variable "db-cpu" {
  default= 512
}

variable "db-memory" {
  default = 1024
}

variable "db-max-capacity" {
  default = 1
}

variable "db-min-capacity" {
  default = 1
}