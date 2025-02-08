output "_________frontend_url" {
  value = "https://${aws_route53_record.frontend.name}"
}

output "__________backend_url" {
  value = "https://${aws_route53_record.backend.name}"
}

output "__________swagger_url" {
  value = "https://${aws_route53_record.backend.name}/docs"
}
output "static_content_bucket" {
  value = "https://${aws_route53_record.static.name}"
}
