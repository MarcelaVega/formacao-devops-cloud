output "lb_dns_name" {
  description = "Load Balancer DNS name for connection/registry in Route53 domain"
  value       = module.alb.lb_dns_name
}

output "dns" {
  value       = [aws_route53_record.main.name,aws_route53_record.www.name]
}