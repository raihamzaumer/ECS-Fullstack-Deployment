output "alb_dns" {
  value = module.ecs.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr_backend.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_names" {
  value = module.ecs.service_names
}

output "acm_certificate_arn" {
  value = module.acm.certificate_arn
}

output "acm_validation_records" {
  value = module.acm.validation_records
}

output "cloudfront_domain" {
  value = module.cloudfront.distribution_domain_name
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}