# Creating a seperate file for ECR so the whole infrastruce can be deployed with one command "terraform apply".
# Also CI Tool can just remove this file when creating the same infra for Testing the application.


/* -------------------------------------------------------------------------- */
/*                                     ECR                                    */
/* -------------------------------------------------------------------------- */
resource "aws_ecr_repository" "my-ecr-repo" {
  count = var.environment == "prod" ? 1 : 0
  name                 = "${var.app-name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}