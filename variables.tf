variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "myapp"
}

variable "environment" {
  type    = string
  default = "dev"
}

####  State S3 

variable "state_bucket_name" {
  type    = string
  default = "Resources-state-bucket-2k26"
}

####   DynamoDB Table

variable "table_name" {
  type = string
}

variable "billing_mode" {
  type = string
}

variable "hash_key" {
  type = string
}

variable "attribute_name" {
  type = string
}

variable "attribute_type" {
  type = string
}

####   FRONTEND S3

variable "frontend_bucket_name" {
  type    = string
  default = "frontend-bucket-2k26"
}
variable "enable_static_website" {
  type = bool
}
variable "enable_versioning" {
  type = bool
}
variable "enable_lifecycle_rule" {
  type = bool
}

variable "enable_logging" {
  type = bool
}

variable "lifecycle_expiration_days" {
  type = number
}

variable "lifecycle_transition_days" {
  type = number
}

variable "lifecycle_storage_class" {
  type = string
}
variable "aliases" {
  description = "Additional CloudFront domain aliases (e.g. www.adeeltech.bar)"
  type        = list(string)
  default     = []
}


###     ACM     ###


variable "domain_name" {
  type = string
}
variable "auto_validate_via_route53" {
  type = bool
}
variable "subject_alternative_names" {
  type = list(string)
}




#### VPC ####

variable "vpc_name" {
  type    = string
  default = "MyVPC"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "enable_nat_gateway" { type = bool }
variable "create_eip" { type = bool }

variable "create_app_sg" { type = bool }
variable "create_elb_sg" { type = bool }
variable "create_db_sg" { type = bool }

variable "elb_ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
}


####    ECR    ####

variable "repository_name" {
  type = string
}
variable "scan_on_push" {
  type = bool
}


####   SECRETS MANAGER


variable "secrets_name" {
  type = string
}
variable "mongo_uri" {
  type      = string
  sensitive = true
}


#### ECS ####

variable "enable_alb" { type = bool }
# variable "enable_https" { type = bool }
# variable "listener_mode" {
#   type    = string
#   default = "http_to_https"

#   validation {
#     condition     = contains(["http_only", "https_only", "http_to_https", "dual"], var.listener_mode)
#     error_message = "listener_mode must be http_only, https_only, http_to_https, or dual"
#   }
# }
variable "enable_logs" { type = bool }
variable "enable_exec" { type = bool }

variable "deployment_min_healthy" { type = number }
variable "deployment_max_percent" { type = number }
variable "enable_blue_green" {
  type = bool
}
variable "FRONTEND_URL" {
  type = string
}
variable "jwt_secret" {
  type      = string
  sensitive = true
}
variable "log_retention_days" {
  type    = number
  default = 7
}

variable "health_check_grace_period" {
  type    = number
  default = 60
}

variable "assign_public_ip" { type = bool }

## cloudfront


