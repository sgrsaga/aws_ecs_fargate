# Create ECR repository for the image to store
resource "aws_ecr_repository" "project_repo" {
  name = "project_repo_aws"
  image_tag_mutability = "MUTABLE"
  force_delete = true # This will remove the repo with all the images as well in it.

  image_scanning_configuration {
    scan_on_push = true
  }
}

## SNS Topic
resource "aws_sns_topic" "ecr_bg" {
  name = "ecs-bg-topic"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "project_cluster" {
  name = "project_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

