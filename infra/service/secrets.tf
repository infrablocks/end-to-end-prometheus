locals {
  prometheus_dns_name = "${var.component}-${var.deployment_identifier}.${data.terraform_remote_state.domain.outputs.domain_name}"

  env_file_object_key = "prometheus/service/environments/default.env"
  env_file_object_path = "s3://${var.secrets_bucket_name}/${local.env_file_object_key}"

  configuration_file_object_key = "prometheus/service/configuration/prometheus.yml"
  configuration_file_object_path = "s3://${var.secrets_bucket_name}/${local.configuration_file_object_key}"

  env = templatefile("${path.root}/envfiles/prometheus.env.tpl", {
    prometheus_dns_name = local.prometheus_dns_name
    prometheus_configuration_file_object_path = local.configuration_file_object_path
  })
  configuration = templatefile("${path.root}/configuration/prometheus.yml.tpl", {})
}

resource "aws_s3_object" "env" {
  key = local.env_file_object_key
  bucket = var.secrets_bucket_name
  content = local.env

  server_side_encryption = "AES256"
}

resource "aws_s3_object" "configuration" {
  key = local.configuration_file_object_key
  bucket = var.secrets_bucket_name
  content = local.configuration

  server_side_encryption = "AES256"
}
