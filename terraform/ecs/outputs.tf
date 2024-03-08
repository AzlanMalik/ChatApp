output "lb-url" {
  value = aws_lb.my-application-load-balancer.dns_name
}

output "ecr-url" {
  value = aws_ecr_repository.my-ecr-repo.repository_url
}