####################################
## Create CodeBuild role

# DEfine Few Local variables
locals {
  log_group = "codebuild_log_group"
  repo_name = "blue_green_repo"
  codebuild_project = "ECS_Build"
  artifact_s3_bucket = "code-artifact-sgr-20230530" 
  cloudwatch_logs = "CodeBuildLG"
}

# Create IAM Role
resource "aws_iam_role" "CodeBuildRoleForECS" {
  name = "CodeBuildRoleForECS"

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


## Creating policy for CodeBuildRoleForECS
resource "aws_iam_role_policy" "CodeBuildRoleForECS_policy" {
  name = aws_iam_role.CodeBuildRoleForECS.name
  role = aws_iam_role.CodeBuildRoleForECS.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-ap-south-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "logs:ListTagsLogGroup",
                "logs:GetDataProtectionPolicy",
                "logs:DeleteDataProtectionPolicy",
                "logs:DeleteSubscriptionFilter",
                "logs:DescribeLogStreams",
                "logs:DescribeSubscriptionFilters",
                "logs:StartQuery",
                "logs:DescribeMetricFilters",
                "logs:CreateExportTask",
                "logs:CreateLogStream",
                "logs:DeleteMetricFilter",
                "logs:DeleteRetentionPolicy",
                "logs:AssociateKmsKey",
                "logs:FilterLogEvents",
                "logs:DisassociateKmsKey",
                "logs:PutDataProtectionPolicy",
                "logs:DescribeLogGroups",
                "logs:DeleteLogGroup",
                "logs:Unmask",
                "logs:CreateLogGroup",
                "logs:ListTagsForResource",
                "logs:PutMetricFilter",
                "logs:PutSubscriptionFilter",
                "logs:PutRetentionPolicy",
                "logs:GetLogGroupFields"
            ],
            "Resource": "arn:aws:logs:*:598792377165:log-group:*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "logs:PutDestinationPolicy",
                "logs:GetLogEvents",
                "logs:DeleteDestination",
                "logs:PutSubscriptionFilter",
                "logs:PutDestination",
                "logs:DeleteLogStream",
                "logs:PutLogEvents",
                "logs:ListTagsForResource"
            ],
            "Resource": [
                "arn:aws:logs:*:598792377165:log-group:*:log-stream:*",
                "arn:aws:logs:*:598792377165:destination:*"
            ]
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeQueries",
                "logs:GetLogRecord",
                "logs:StopQuery",
                "logs:TestMetricFilter",
                "logs:DeleteQueryDefinition",
                "logs:PutQueryDefinition",
                "logs:GetLogDelivery",
                "logs:ListLogDeliveries",
                "logs:Link",
                "logs:CreateLogDelivery",
                "logs:DescribeExportTasks",
                "logs:GetQueryResults",
                "logs:UpdateLogDelivery",
                "logs:CancelExportTask",
                "logs:DeleteLogDelivery",
                "logs:DescribeQueryDefinitions",
                "logs:DescribeResourcePolicies",
                "logs:DescribeDestinations"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:codecommit:ap-south-1:${data.aws_caller_identity.caller_identity.account_id}:${local.repo_name}"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${local.artifact_s3_bucket}",
                "arn:aws:s3:::${local.artifact_s3_bucket}/*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Sid": "VisualEditor6",
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:ap-south-1:${data.aws_caller_identity.caller_identity.account_id}:build/${local.codebuild_project}-*"
            ]
        },
        {
            "Sid": "VisualEditor7",
            "Effect": "Allow",
            "Action": [
                "ecr:GetRegistryPolicy",
                "ecr:CreateRepository",
                "ecr:DescribeRegistry",
                "ecr:DescribePullThroughCacheRules",
                "ecr:GetAuthorizationToken",
                "ecr:PutRegistryScanningConfiguration",
                "ecr:CreatePullThroughCacheRule",
                "ecr:DeletePullThroughCacheRule",
                "ecr:PutRegistryPolicy",
                "ecr:GetRegistryScanningConfiguration",
                "ecr:BatchImportUpstreamImage",
                "ecr:DeleteRegistryPolicy",
                "ecr:PutReplicationConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor8",
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "arn:aws:ecr:*:${data.aws_caller_identity.caller_identity.account_id}:repository/*"
        },
        {
            "Sid": "VisualEditor9",
            "Effect": "Allow",
            "Action": "ec2:DescribeSecurityGroups",
            "Resource": "*"
        }
    ]
})
}

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
    /*
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
    */
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
    /*
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
    */
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
  
  ## Remove the loadbalancer from ECS service and assign from CodeDeploy
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_tg1.arn
    container_name   = "AppTask"
    container_port   = 80
  }
  /*
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_tg2.arn
    container_name   = "AppTask"
    container_port   = 80
  }
  */
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
}


# Manually create and refer due to default branch requirement
## Code Commit
resource "aws_codecommit_repository" "repo" {
  repository_name = "${local.repo_name}"
  description     = "${local.repo_name} Repository"
}


/*
resource "aws_cloudwatch_event_rule" "commit" {
  name        = "blue_green_repocapture-commit-event"
  description = "Capture blue_green_repo repo commit"

  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
   "${data.aws_codecommit_repository.repo.arn}"
  ],
  "detail": {
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "master"
    ]
  }
}
EOF
}
*/

/*
resource "aws_cloudwatch_event_target" "event_target" {
  target_id = "1"
  rule      = aws_cloudwatch_event_rule.commit.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.codepipeline_role.arn
}
*/

# S3 bucket for Artifacts
resource "aws_s3_bucket" "code_artifact" {
  bucket = "${local.artifact_s3_bucket}"
  force_destroy = true ## To handle none empty S3 bucket. Destroy with Terraform destroy.

  tags = {
    Name        = "code_artifact"
    Environment = "Dev"
  }
}

## Code Build
resource "aws_codebuild_project" "codebuild" {
  name          = "${local.codebuild_project}"
  description   = "${local.codebuild_project} Codebuild Project"
  build_timeout = "5"
  ## HARD Coded role
  service_role  = aws_iam_role.CodeBuildRoleForECS.arn
  source_version = "refs/heads/master"
  artifacts {
    type = "S3"
    location = aws_s3_bucket.code_artifact.bucket
    override_artifact_name = true
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.project_repo.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.caller_identity.account_id
    }
  }
  vpc_config {
    vpc_id = var.vpc_id
    subnets = data.aws_subnets.private_subnets.ids
    security_group_ids = [ data.aws_security_group.private_sg.id ]
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "${local.cloudwatch_logs}"
    }
  }
  project_visibility = "PRIVATE"
  source {
    type      = "CODECOMMIT"
    buildspec = "buildspec.yml"
    location = aws_codecommit_repository.repo.clone_url_http
    git_clone_depth = 1
  }
}


/*
#CodeBuild Pipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "CodePipeline"
  # Hard code role
  role_arn = "arn:aws:iam::598792377165:role/service-role/AWSCodePipelineServiceRole-ap-south-1-MyNewPipeline_without_cod"

  artifact_store {
    location = aws_s3_bucket.code_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName        = aws_codecommit_repository.repo.repository_name
        BranchName            = "master"
        PollForSourceChanges  = false
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      name            = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ApplicationName                = "ECS_Deploy"
        DeploymentGroupName            = "ECS_Deploy_Group"
        AppSpecTemplateArtifact        = "source_output"
        AppSpecTemplatePath            = "appspec.yaml"
        TaskDefinitionTemplateArtifact = "source_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
    }
  }
}
*/