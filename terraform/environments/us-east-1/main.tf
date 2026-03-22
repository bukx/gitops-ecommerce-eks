terraform {
  required_version = ">= 1.5"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" {
    bucket = "ecommerce-tfstate-prod"; key = "us-east-1/terraform.tfstate"
    region = "us-east-1"; dynamodb_table = "terraform-locks"; encrypt = true
  }
}

provider "aws" { region = "us-east-1"; default_tags { tags = local.common_tags } }

locals {
  environment = "prod"; region = "us-east-1"; project = "ecommerce-platform"
  common_tags = { Project = local.project, Environment = local.environment, Region = local.region, ManagedBy = "terraform" }
}

module "vpc" {
  source = "../../modules/vpc"
  name = "${local.project}-${local.region}"; cidr = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true; single_nat_gateway = false; tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"
  cluster_name = "${local.project}-${local.region}"; vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids; node_instance_types = ["t3.large"]
  node_desired_size = 3; tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"
  identifier = "${local.project}-db-${local.region}"; engine_version = "15.4"
  instance_class = "db.r6g.large"; allocated_storage = 100; multi_az = true
  vpc_id = module.vpc.vpc_id; subnet_ids = module.vpc.private_subnet_ids
  backup_retention = 7; deletion_protection = true; tags = local.common_tags
}

module "elasticache" {
  source = "../../modules/elasticache"
  cluster_id = "${local.project}-cache-${local.region}"; node_type = "cache.r6g.large"
  num_cache_nodes = 2; vpc_id = module.vpc.vpc_id; subnet_ids = module.vpc.private_subnet_ids
  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"
  repository_names = ["catalog-service", "cart-service", "checkout-service"]; tags = local.common_tags
}

output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "rds_endpoint"         { value = module.rds.endpoint }
output "redis_endpoint"       { value = module.elasticache.endpoint }
