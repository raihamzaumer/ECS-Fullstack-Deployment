module "s3_frontend" {
  source = "./modules/S3"

  bucket_name                 = var.frontend_bucket_name
  project_name                = var.project_name
  environment                 = var.environment
  access_mode                 = "cloudfront"
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  enable_static_website       = var.enable_static_website
  enable_versioning           = var.enable_versioning
  enable_lifecycle_rule       = var.enable_lifecycle_rule
  lifecycle_expiration_days   = var.lifecycle_expiration_days
  lifecycle_transition_days   = var.lifecycle_transition_days
  lifecycle_storage_class     = var.lifecycle_storage_class
  enable_logging              = var.enable_logging

}


####        CloudFront      ####


module "cloudfront" {
  source = "./modules/CloudFront"

  project_name = var.project_name
  environment  = var.environment

  default_origin_id      = "frontend"
  origin_protocol_policy = "http-only"

  origins = [
    {
      id          = "frontend"
      domain_name = module.s3_frontend.bucket_domain_name
      type        = "s3"
      bucket_name = module.s3_frontend.bucket_name
      bucket_arn  = module.s3_frontend.bucket_arn
    },
    {
      id          = "api"
      domain_name = module.ecs.alb_dns_name
      type        = "custom"
    }
  ]

  behaviors = [
    {
      path_pattern     = "/api/*"
      target_origin_id = "api"
      is_api           = true
    },
    {
      path_pattern     = "/health"
      target_origin_id = "api"
      is_api           = true
    },
    {
      path_pattern     = "/*"
      target_origin_id = "frontend"
      is_api           = false
    }
  ]

  domain_name         = var.domain_name
  aliases             = var.aliases
  acm_certificate_arn = module.acm.certificate_arn

  enable_oac              = true
  enable_spa_fallback     = true
  enable_security_headers = true
}