/* -------------------------------------------------------------------------- */
/*                                  VARIABLES                                 */
/* -------------------------------------------------------------------------- */

# Create a terraform.tfvars file for keeping credentials secure
variable "aws-access-key" {
  description = "Provide the AWS Access Key that you generated"
}

variable "aws-secret-key" {
  sensitive   = true
  description = "Provide the AWS Secret Key that you generated"
}

variable "aws-region" {
  sensitive   = true
  description = "Provide the AWS Region"
}

variable "app-name" {
  description = "Add your project name here"
}

variable "environment" {
  description = "provide environment name such as Dev/Staging/Prod"
}

/* --------- For Testing Environment/ Updating the Image of Services -------- */
# Keep them default for the first time
variable "db-ecr-url" {
  type        = string
  default     = "mysql:latest"
  description = "ECR DB Docker Image URl for Testing/Staging in CI"
}

variable "app-ecr-url" {
  type        = string
  default     = "php:apache"
  description = "ECR APP Docker Image URL for Testing/Staging in CI"
}


/* -------------------------------------------------------------------------- */
/*                           APP - SERVICE VARIABLES                          */
/* -------------------------------------------------------------------------- */
variable "app-cpu" {
  type        = number
  description = "APP service CPU allocated to each container - 1cpu = 1024"
  default     = 512
}

variable "app-memory" {
  type        = number
  description = "APP service RAM/Memory allocated to each container - 1GB Memory = 1024"
  default     = 1024
}

variable "app-max-capacity" {
  type        = number
  description = "Maximum Containers limit when the APP service is Scaling Up"
  default     = 2
}

variable "app-min-capacity" {
  type        = number
  description = "Mininmum Containers limit when the APP service is Scaling Down or Desired Number of Container when idle"
  default     = 2
}

/* -------------------------------------------------------------------------- */
/*                           DB - SERVICE VARIABLES                           */
/* -------------------------------------------------------------------------- */
variable "db-cpu" {
  type        = number
  description = "DB service CPU allocated to each container - 1cpu = 1024"
  default     = 512
}

variable "db-memory" {
  type        = number
  description = "DB service RAM/Memory allocated to each container - 1GB Memory = 1024"
  default     = 1024
}

variable "db-max-capacity" {
  type        = number
  description = "Maximum Containers limit when the DB service is Scaling Up"
  default     = 1
}

variable "db-min-capacity" {
  type        = number
  description = "Mininmum Containers limit when the DB service is Scaling Down or Desired Number of Container when idle"
  default     = 1
}

/* -------------------------------------------------------------------------- */
/*                              NETWORK VARIABLES                             */
/* -------------------------------------------------------------------------- */
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

