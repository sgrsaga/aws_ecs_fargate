# ECR Image URL
output "ecr_image_url" {
    value = aws_ecr_repository.project_repo.repository_url
}

# SNS Topic ARN
output "sns_topic" {
    value = aws_sns_topic.ecr_bg.arn 
}


## ECS Cluster name
output "ecs_cluster" {
    value = aws_ecs_cluster.project_cluster 
}