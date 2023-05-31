#### VPC Variables ####
variable "vpc_id" {
    type = string  
}

### ALB Access logs saving bucket name
variable "alb_access_log_s3_bucket" {
    type = string
}