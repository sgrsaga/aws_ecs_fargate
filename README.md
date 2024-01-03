
# AWS ECS Fargate Complete Infrastructure provisioning project

In this project we discuss how we can implement a complete AWS ECS Frgate environment with Terraform and GitHub actions pipeline to host container workloads.

## Technologies and Tools 
-  AWS as the Hosting Cloud provider
- Terraform as the Infrastructure as Code Tool
- GitHub for IaC code hosting and GitHub actions for CI/CD pipeline
- AWS Codepipeline to implement Blue Green Deployment stratrgy.
- AWS CLI

### Prerequisites
##### 1. Active domain in Route53
##### 2. GitLab OIDC configuration between GitLab project and AWS 

## Infrastructure Resources and Highlevel connectivity

- AWS Network (VPC, Internet Gateway, Subnets, Route Tables, Nat Gateway, Security Groups)
- AWS Fargate Based ECS cluster (ECS Cluster, Fargate Compute, ECS Service, ECS Tasks, ECR)
- AWS Codepipeline , CodeDeploy and Blue Green Deployment stratergy
- AWS Application Load Balancer and Target Group
- AWS RDS (Postgres Database server)
- AWS Secret Manager
- Route 53 and AWS Certificat eManager
- CloudWatch and SNS for Obervability and notifications

![High Level architecture](images/ECS-Fargate.png)

## GitHub Action pipeline
![GitLab pipeline](images/GitLab-CodePipeline.png)

## Hi, I'm Sagara! 👋


## 🚀 About Me
I am an engineer with over 13 years of experience in the IT industry, working with various domains such as education, procurement, travel management, and corporate finance. I have multiple AWS certifications, a Kubernetes Certification, a HashiCorp Terraform certification and RedHat Certifications that demonstrate my proficiency and knowledge in Cloud engineering, DevOps engineering and Infrastructure automation.

