# ECR Image URL
output "ecr_image_url" {
    value = aws_ecr_repository.project_repo.repository_url
}

# SNS Topic ARN
output "sns_topic" {
    value = aws_sns_topic.ecr_bg.arn 
}

## ECS Cluster name
output "cluster_name" {
    value = aws_ecs_cluster.project_cluster.name
}

## ECS Cluster service name
output "service_name" {
    value = aws_ecs_service.service_node_app.name
}

## Prod Listner
output "prod_listner_arn" {
  value = aws_lb_listener.alb_to_tg1.arn
}

## Test Listner
output "test_listner_arn" {
  value = aws_lb_listener.alb_to_tg2.arn
}

## TargetGroup 1
output "tg1" {
  value = aws_lb_target_group.ecs_alb_tg1.name
}

## TargetGroup 2
output "tg2" {
  value = aws_lb_target_group.ecs_alb_tg2.name
}
