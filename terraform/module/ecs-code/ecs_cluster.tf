############################################################
########## Create dependancy service for ECS Cluster service

## Get Public Security Group to apply for the Database
data "aws_security_group" "public_sg" {
  tags = {
    Name = "PUBLIC_SG"
  }
}

## Get Private Security Group to apply for the Database
data "aws_security_group" "private_sg" {
  tags = {
    Name = "PRIVATE_SG"
  }
}

## Get Public SubnetList
data "aws_subnets" "public_subnets" {
    filter {
      name = "tag:Access"
      values = ["PUBLIC"]
    }
}

## Get Private SubnetList
data "aws_subnets" "private_subnets" {
    filter {
      name = "tag:Access"
      values = ["PRIVATE"]
    }
}

## GEt the service Account ID
data "aws_elb_service_account" "service_account_id" {}
## Get the callert identity
data "aws_caller_identity" "caller_identity" {}

## Create S3 bucket for access_logs
resource "aws_s3_bucket" "lb_logs" {
  bucket = var.alb_access_log_s3_bucket
  force_destroy = true ## To handle none empty S3 bucket. Destroy with Terraform destroy.
  
  tags = {
    Name        = "ALB_LOG_Bucket"
  }
}


## Create ecsTaskExecutionRole
resource "aws_iam_role" "ecsTaskExecutionRoleNew" {
  name = "ecsTaskExecutionRoleNew"

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "EcsTaskExcPolicyRoleAttach_policy" {
  name = aws_iam_role.ecsTaskExecutionRoleNew.name
  role = aws_iam_role.ecsTaskExecutionRoleNew.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
})
}

## Apply bucket policy to the bucket
resource "aws_s3_bucket_policy" "access_logs_policy" {
    bucket = aws_s3_bucket.lb_logs.id
    policy = jsonencode({
    Version: "2012-10-17",
    Id: "AWSConsole-AccessLogs-Policy-1668059634986",
    Statement: [
        {
            Sid: "AWSConsoleStmt-1668059634986",
            Effect: "Allow",
            Principal: {
                AWS: "${data.aws_elb_service_account.service_account_id.arn}"
            },
            Action: "s3:PutObject",
            Resource: "${aws_s3_bucket.lb_logs.arn}/AWSLogs/${data.aws_caller_identity.caller_identity.account_id}/*"
        },
        {
            Sid: "AWSLogDeliveryWrite",
            Effect: "Allow",
            Principal: {
                Service: "delivery.logs.amazonaws.com"
            },
            Action: "s3:PutObject",
            Resource: "${aws_s3_bucket.lb_logs.arn}/AWSLogs/${data.aws_caller_identity.caller_identity.account_id}/*",
            Condition: {
                StringEquals: {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            Sid: "AWSLogDeliveryAclCheck",
            Effect: "Allow",
            Principal: {
                "Service": "delivery.logs.amazonaws.com"
            },
            Action: "s3:GetBucketAcl",
            Resource: "${aws_s3_bucket.lb_logs.arn}"
        }
    ]
    })
}

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

# Create Application Load balancer
resource "aws_lb" "ecs_lb" {
  name               = "opstools-ppe"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.public_sg.id]
  subnets            = data.aws_subnets.public_subnets.ids
  ip_address_type = "ipv4"

  enable_deletion_protection = false
  tags = {
    Environment = "Project"
  }
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    enabled = true
  }
  depends_on = [
    aws_s3_bucket.lb_logs,
    aws_s3_bucket_policy.access_logs_policy
  ]
  drop_invalid_header_fields = true
}



# Target Group for ALB Primary
resource "aws_lb_target_group" "ecs_alb_tg1" {
  name     = "ecs-alb-tg1"
  target_type = "ip"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    unhealthy_threshold = "2"
    timeout             = "20"
    path                = "/"
  }
}

# Target Group for ALB Secondary
resource "aws_lb_target_group" "ecs_alb_tg2" {
  name     = "ecs-alb-tg2"
  target_type = "ip"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    unhealthy_threshold = "2"
    timeout             = "20"
    path                = "/"
  }
}


# Links ALB to TG with lister rule primary
resource "aws_lb_listener" "alb_to_tg1" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.ecs_alb_tg1.id
    type = "forward"
  }
  lifecycle {
    ignore_changes = [ default_action ]
  }
}

# Links ALB to TG with lister rule secondary
resource "aws_lb_listener" "alb_to_tg2" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port = 8080
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.ecs_alb_tg2.id
    type = "forward"
  }
  lifecycle {
    ignore_changes = [ default_action ]
  }
}

# Create a ecs task definitions
resource "aws_ecs_task_definition" "project_task" {
  family                   = "project_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn = aws_iam_role.ecsTaskExecutionRoleNew.arn
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = jsonencode([
    {
      name = "AppTask"
      image = aws_ecr_repository.project_repo.repository_url
      cpu = 10
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


# ECS Service configuration for Blue-Green deployment
resource "aws_ecs_service" "service_node_app" {
  name            = "service_node_app"
  cluster         = aws_ecs_cluster.project_cluster.id
  task_definition = aws_ecs_task_definition.project_task.arn
  enable_ecs_managed_tags = true
  desired_count   = 2
  launch_type = "FARGATE"
  health_check_grace_period_seconds = 60
  wait_for_steady_state = false
  scheduling_strategy = "REPLICA"
  #iam_role        = aws_iam_role.ecsServiceRoleNew.arn
  network_configuration {
    subnets = data.aws_subnets.private_subnets.ids
    assign_public_ip = false
    security_groups = [data.aws_security_group.private_sg.id]
  }
  depends_on      = [
    aws_ecs_cluster.project_cluster, 
    aws_ecs_task_definition.project_task,
    aws_lb_listener.alb_to_tg1,
    aws_lb_listener.alb_to_tg2,
    aws_lb_target_group.ecs_alb_tg1,
    aws_lb_target_group.ecs_alb_tg2
    ]
  lifecycle {
    ignore_changes = [desired_count]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_tg1.arn
    container_name   = "AppTask"
    container_port   = 80
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
}

