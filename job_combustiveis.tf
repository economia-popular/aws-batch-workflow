resource "aws_batch_job_definition" "indices_combustiveis" {
  name = format("%s-indices-combustiveis", var.project_name)
  
  type = "container"

  timeout {
    attempt_duration_seconds = var.job_timeout * 4
  }

  platform_capabilities = [
    var.computing_type
  ]

  propagate_tags = true

  container_properties = <<CONTAINER_PROPERTIES
{
  "image": "${aws_ecr_repository.indices_combustiveis.repository_url}:latest",
  "fargatePlatformConfiguration": {
    "platformVersion": "LATEST"
  },
  "resourceRequirements": [
    {"type": "VCPU", "value": "${var.vcpu}"},
    {"type": "MEMORY", "value": "${var.memory}"}
  ],
  "environment": [
    {"name": "REGION", "value": "${var.aws_region}"},
    {"name": "JOB_TIMEOUT", "value": "${var.job_timeout}"}
  ],  
  "executionRoleArn": "${aws_iam_role.main.arn}",
  "networkConfiguration" : {
    "assignPublicIp": "ENABLED"
  },
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {},
    "secretOptions": []
  },
  "jobDefinitionArn": "${aws_iam_role.main.arn}",
  "jobRoleArn": "${aws_iam_role.main.arn}"
}
CONTAINER_PROPERTIES
}

resource "aws_batch_compute_environment" "indices_combustiveis" {
  compute_environment_name = format("%s-indices-combustiveis", var.project_name)

  compute_resources {
    spot_iam_fleet_role = var.computing_type == "FARGATE_SPOT"  ? aws_iam_role.main.arn : null 

    max_vcpus = var.max_vcpus

    security_group_ids = [
      aws_security_group.main.id,
    ]

    subnets = var.private_subnets

    type = var.computing_type
  }

  service_role = aws_iam_role.main.arn
  type         = "MANAGED"
  depends_on = [
    aws_iam_role_policy_attachment.ecs,
    aws_iam_role_policy_attachment.batch
  ]
}

resource "aws_batch_job_queue" "indices_combustiveis" {
  name = format("%s-indices-combustiveis", var.project_name)

  state                 = "ENABLED"
  priority              = 1

  compute_environments = [
    aws_batch_compute_environment.indices_combustiveis.arn
  ]
}

resource "aws_batch_scheduling_policy" "indices_combustiveis" {
  name = format("%s-indices-combustiveis", var.project_name)
}


resource "aws_cloudwatch_event_target" "indices_combustiveis" {
  rule = aws_cloudwatch_event_rule.main.name
  arn  = aws_batch_job_queue.indices_combustiveis.arn

  role_arn = aws_iam_role.cloudwatch.arn

  batch_target {
    job_name       = format("%s-indices-combustiveis", var.project_name)
    job_definition = aws_batch_job_definition.indices_combustiveis.arn
    array_size     = var.batch_array_size
    job_attempts   = var.batch_attempts
  }

}