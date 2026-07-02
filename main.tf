provider "aws" {
  region = var.aws_region
}

####    State Locking     ####

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }
}

#####          S3       #####

module "s3_state_bucket" {
  source = "./modules/S3"

  bucket_name       = var.state_bucket_name
  access_mode       = "private"
  enable_versioning = true
  project_name      = var.project_name
  environment       = var.environment
}


####      ACM     ####

module "acm" {
  source = "./modules/ACM"

  project_name = var.project_name
  environment  = var.environment

  domain_name               = var.domain_name
  auto_validate_via_route53 = var.auto_validate_via_route53
  subject_alternative_names = var.subject_alternative_names

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

####      VPC      ####

module "vpc" {
  source = "./modules/VPC"

  project_name    = var.project_name
  environment     = var.environment
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs

  enable_nat_gateway = var.enable_nat_gateway
  create_eip         = var.create_eip

  create_app_sg = var.create_app_sg
  create_elb_sg = var.create_elb_sg
  create_db_sg  = var.create_db_sg

  elb_ingress_rules = var.elb_ingress_rules

  app_ingress_rules = [
    {
      from_port       = 5001
      to_port         = 5001
      protocol        = "tcp"
      security_groups = [module.vpc.elb_sg_id]
    }
  ]
}


####     Secrets Manager  ####


module "mongo_secret" {
  source = "./modules/Secrets-Manager"

  project_name = var.project_name
  environment  = var.environment

  name        = var.secrets_name
  description = "MongoDB connection string"

  secret_map = {
    MONGO_URI = var.mongo_uri
  }
}


####     ECR      ####

module "ecr_backend" {
  source = "./modules/ECR"

  project_name    = var.project_name
  environment     = var.environment
  repository_name = var.repository_name
  scan_on_push    = var.scan_on_push

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

####     ECS      ####

module "ecs" {
  source = "./modules/ECS"

  project_name = var.project_name
  environment  = var.environment
  region       = var.aws_region

  subnets         = module.vpc.private_subnet_ids
  security_groups = [module.vpc.app_sg_id]

  enable_alb = var.enable_alb
  vpc_id     = module.vpc.vpc_id

  alb_subnets         = module.vpc.public_subnet_ids
  alb_security_groups = [module.vpc.elb_sg_id]

  assign_public_ip = var.assign_public_ip


  listener_mode   = "dual"
  certificate_arn = module.acm.certificate_arn

  # ---------------- SECRETS ----------------
  secrets_arns = [module.mongo_secret.secret_arn]

  # ---------------- LOGGING ----------------
  enable_logs               = var.enable_logs
  log_retention_days        = var.log_retention_days
  health_check_grace_period = var.health_check_grace_period

  # ---------------- DEPLOYMENT ----------------
  enable_exec            = var.enable_exec
  deployment_min_healthy = var.deployment_min_healthy
  deployment_max_percent = var.deployment_max_percent
  enable_blue_green      = var.enable_blue_green
  default_service        = "backend"

  services = {
    backend = {
      image                 = "${module.ecr_backend.repository_url}:latest"
      port                  = 5001
      cpu                   = "512"
      memory                = "1024"
      desired_count         = 1
      path                  = "/api/*"
      priority              = 1
      health_check_path     = "/health"
      health_check_protocol = "HTTP"
      health_check_matcher  = "200"

      env = {
        FRONTEND_URL = var.FRONTEND_URL
        JWT_SECRET   = var.jwt_secret
      }

      # secrets = [
      #   {
      #     name      = "MONGO_URI"
      #     valueFrom = module.mongo_secret.secret_arn
      #   }
      # ]
      secrets = [
      {
    name      = "MONGO_URI"
    valueFrom = "${module.mongo_secret.secret_arn}:MONGO_URI::"
      }
]

      enable_autoscaling = true
      min_capacity       = 1
      max_capacity       = 3

      cpu_target     = 20
      memory_target  = 70
      request_target = 200
    }
  }

  depends_on = [
    module.mongo_secret,
    module.acm,
  ]
}

