resource "aws_cloudwatch_event_rule" "main" {
  name        = var.project_name
  description = var.project_name

  schedule_expression = var.batch_scheduler
}