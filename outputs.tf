output "prod_alb_dns" {
  value       = aws_lb.prod_alb.dns_name
  description = "DNS name of the production ALB"
}

output "test_alb_dns" {
  value       = aws_lb.test_alb.dns_name
  description = "DNS name of the testing ALB"
}

output "prod_route53_record" {
  value       = aws_route53_record.prod_record.fqdn
  description = "Route 53 record for production"
}

output "test_route53_record" {
  value       = aws_route53_record.test_record.fqdn
  description = "Route 53 record for testing"
}
