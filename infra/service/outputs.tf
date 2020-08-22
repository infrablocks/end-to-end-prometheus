output "address" {
  value = data.template_file.prometheus_dns_name.rendered
}