resource "aws_dynamodb_table" "deployment_logs_table" {
  name         = "deployment-step-service-prod-logs-${var.agent_key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "timestamp"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "deployment_remote_run_logs_table" {
  name         = "deployment-step-service-prod-remote-run-logs-${var.agent_key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "deploymentLogId"
  range_key    = "offsetStart"

  attribute {
    name = "deploymentLogId"
    type = "S"
  }

  attribute {
    name = "offsetStart"
    type = "N"
  }

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}