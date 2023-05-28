## Create IAM user
#username = "profbob"

###### VPC parameters
# 1. Create a VPC
vpc_name = "OpsTools-VPC-dev"
vpc_cidr = "10.0.0.0/16"
public_source_cidr = ["0.0.0.0/0"]
public_source_cidr_v6 = ["::/0"]
#azs = ["ap-south-1a","ap-south-1b","ap-south-1c"]

# 2. Create a Internet Gateway
ig_name = "OpsTools_IG"

# 1.3. Create 2 Route tables
public_rt = "PUBLIC_RT"
private_rt = "PRIVATE_RT"

# 1.4. Create 3 Public Subnets
public_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
# 1.5. Create 3 Private Subnets
private_subnets = ["10.0.7.0/24","10.0.8.0/24","10.0.9.0/24"]

# 1.6. Create Public access Security Group
public_access_sg_ingress_rules = [
    {
      protocol = "tcp"
      from_port = 80
      to_port = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol = "tcp"
      from_port = 22
      to_port = 22
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol = "tcp"
      from_port = 443
      to_port = 443
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol = "tcp"
      from_port = 8080
      to_port = 8080
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]


  ### ------------- Database related Variables
db_identifier = "opstools-ppe"
db_backup_retention_period = 7
db_class = "db.t3.medium"
db_delete_protect = "false"  # When it goes PRODUCTION this should be True
db_subnet_group_name = "aurora_postgres_sg"
db_engine = "aurora-postgresql"
db_engine_version = "15.2"
db_name = "OpsTools_db"
db_para_group_name = "default.aurora-postgresql15"
db_storage = 100
db_iops = 300
#db_storage_type = "standard" # # Aurora not supporting storage type
db_username = "opstoolsppe"
is_storage_encrypted = "true"
#max_allocated_storage_value = 500 # Aurora not support
muli_az_enable = "false" # MultiAZ is not available for aurora-postgresql type
db_multiaz = ["us-east-1a","us-east-1b"] # For dev only 1 region is considered ["ap-south-1a","ap-south-1b"]

/*
############ Monitor and Alarm
delivery_email = "sagara.jayathilaka@pearson.com"
bill_threshold_amount = 3
*/

############ ECS Cluster variables
alb_access_log_s3_bucket = "alb-access-logs-sgr-dev-20230406"
## Autosacling EC2 parameters
#ec2_image_id = "ami-03dbf0c122cb6cf1d"
#ec2_instance_type = "t2.micro"
#ssh_keyname = "newkey"
max_tasks = 3
min_tasks = 2
asg_avg_cpu_target = 1.75
ecs_task_avg_cpu_target = 0.25

############# Route 53 #####
#domain_name_used = "devops-expert.online"
