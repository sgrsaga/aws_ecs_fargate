## Add the provide section.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.44.0"  ## was 3.65.0, 4.38.0
    }
  }
}

/*
## Setting the AWS S3 as the Terraform backend
terraform {
  backend "s3" {
    bucket = "terraform-state-pteops-ppe-20230404"
    key    = "terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    dynamodb_table = "opstools_status_lock"
  }
}
*/
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}



provider "aws" {
  region = "ap-south-1"
  default_tags {
   tags = {
     t_environment  = "dev"
     t_AppID = "SVC02193"
     t_dcl = "3"
   }
 }
}


## 1. Call the Network module to generate VPC components
module "main_network" {
  source = "../module/network"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  public_source_cidr = var.public_source_cidr
  public_source_cidr_v6 = var.public_source_cidr_v6
  ig_name = var.ig_name

  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  public_access_sg_ingress_rules = var.public_access_sg_ingress_rules
  public_rt = var.public_rt
  private_rt = var.private_rt
}

/*
## 2. Call Databse creation module
module "aurora_pg_database" {
  source = "../module/rds"
  db_identifier = var.db_identifier
  vpc_id = module.main_network.vpc_id
  db_name = var.db_name
  db_subnet_group_name = var.db_subnet_group_name
  db_engine = var.db_engine
  db_class = var.db_class
  db_engine_version = var.db_engine_version
  db_para_group_name = var.db_para_group_name
  db_storage = var.db_storage
  db_username = var.db_username
  is_storage_encrypted = var.is_storage_encrypted
  muli_az_enable = var.muli_az_enable
  db_multiaz = var.db_multiaz
  db_delete_protect = var.db_delete_protect

  depends_on = [module.main_network] 
 }


## ECS  Module
module "ecs_resources" {
  source = "../module/ecs-code"
  vpc_id = module.main_network.vpc_id
  ## ALB Access logs S3 bucket
  alb_access_log_s3_bucket = var.alb_access_log_s3_bucket
  depends_on = [ module.main_network ]
}

## Code Build and Pipeline
module "build_pipeline" {
  source = "../module/codebuild-pipeline"
  vpc_id = module.main_network.vpc_id
  cluster_name = module.ecs_resources.cluster_name
  service_name = module.ecs_resources.service_name
  tg1 = module.ecs_resources.tg1
  tg2 = module.ecs_resources.tg2
  prod_listner_arn = module.ecs_resources.prod_listner_arn
  test_listner_arn = module.ecs_resources.test_listner_arn
  region = var.region
  depends_on = [ module.ecs_resources ]
}
*/
/*
## Direct ECS Blue Green
module "ecs-service-blue-green-deployment" {
  source  = "hendrixroa/ecs-service-blue-green-deployment/aws"
  version = "2.2.5"
  # insert the 4 required variables here
  ecr_image_url = module.utilities_resources.ecr_image_url
  sns_topic_arn = module.utilities_resources.sns_topic
  port = 80
  environment_list = [{name="foo", value="bar"}]
  cluster = module.utilities_resources.ecs_cluster
  depends_on = [ module.utilities_resources ]
}
*/

/*
## 3. Call ECS creation module
module "ecs_cluster" {
  source = "../module/ecs"
  vpc_id = module.main_network.vpc_id
  ## ALB Access logs S3 bucket
  alb_access_log_s3_bucket = var.alb_access_log_s3_bucket
  ## Autoscaling EC2 parameters
  #ec2_image_id = var.ec2_image_id
  #ec2_instance_type = var.ec2_instance_type
  #ssh_keyname = var.ssh_keyname

  ## MIN and MAX value are used to define minimim and maximum EC2 and Task counts
  max_tasks = var.max_tasks
  min_tasks = var.min_tasks
  ## EC2 autoscaling triggering CPU target value
  asg_avg_cpu_target = var.asg_avg_cpu_target
  ## ECS Service task scaling CPU target value
  ecs_task_avg_cpu_target = var.ecs_task_avg_cpu_target
  depends_on = [module.main_network] 
}
*/

/*

## 4. Route 53 Configuration
module "route53" {
  source = "./module/r53"
  domain_name_used = var.domain_name_used
  target_group_arn = module.ecs_cluster.lb_target_group
  ecs_alb_arn = module.ecs_cluster.ecs_alb
  alb_dns_name = module.ecs_cluster.ecs_alb_dns
  alb_zone_id = module.ecs_cluster.ecs_alb_zone_id 
  depends_on = [
    module.ecs_cluster
  ]
}


## 5. Create monitoring
module "monitor_and_alarm" {
  source = "./module/monitor"
  delivery_email = var.delivery_email
  bill_threshold_amount = var.bill_threshold_amount
  depends_on = [
    module.main_network,
    module.ecs_cluster,
    module.route53
  ]
  
}
*/
