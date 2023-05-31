#### VPC Variables ####
variable "vpc_id" {
    type = string  
}

## Target Group names
variable "tg1" {
    type = string
}

variable "tg2" {
    type = string
}

## ECS Cluster name
variable "cluster_name" {
    type = string
}
## ECS Cluster Service name
variable "service_name" {
    type = string
}

## Production Lister ARN
variable "prod_listner_arn" {
  type = string
}

## Test Lister ARN
variable "test_listner_arn" {
  type = string
}

## Pipeline region
variable "region" {
    type = string  
}