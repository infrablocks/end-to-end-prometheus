locals {
  prometheus_task_container_definitions = templatefile("${path.root}/container-definitions/prometheus.json.tpl", {
    env_file_object_path = local.env_file_object_path
    container_port = var.prometheus_service_container_port
    host_port = var.prometheus_service_host_port
    storage_location = var.prometheus_storage_location
  })
}

module "prometheus_service" {
  source  = "infrablocks/ecs-service/aws"
  version = "4.2.0-rc.8"

  component = var.component
  deployment_identifier = var.deployment_identifier

  region = var.region
  vpc_id = data.aws_vpc.vpc.id

  service_task_container_definitions = local.prometheus_task_container_definitions

  service_name = var.component
  service_image = var.prometheus_image
  service_port = var.prometheus_service_container_port

  service_desired_count = var.service_desired_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 50

  target_group_arn = module.prometheus_load_balancer.target_groups["default"].arn

  service_volumes = [
    {
      name = "prometheus-storage"
      host_path = var.prometheus_storage_location
    }
  ]

  ecs_cluster_id = data.terraform_remote_state.cluster.outputs.ecs_cluster_id
  ecs_cluster_service_role_arn = data.terraform_remote_state.cluster.outputs.ecs_service_role_arn
}
