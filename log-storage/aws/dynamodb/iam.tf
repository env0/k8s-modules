locals {
  deployment_task_runtime_timeout_seconds = 18000 # 5 hours
  env0_aws_account_id          = "913128560467"
  assume_role_policy_statement = [
    {
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${local.env0_aws_account_id}:root"
      }
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.external_id
        }
      }
    },
  ]
}

resource "aws_iam_role" "log_reader" {
  name = "RoleAssumedByEnv0ToReadLogsFromAgent"
  max_session_duration = local.deployment_task_runtime_timeout_seconds

  assume_role_policy = jsonencode({
    Version     = "2012-10-17"
    Statement = local.assume_role_policy_statement
  })

  inline_policy {
    name = "RoleAssumedByEnv0ToReadLogsFromAgentPolicy"

    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "dynamodb:DescribeTable", "dynamodb:Query", "dynamodb:Scan", "dynamodb:GetItem", "dynamodb:BatchGetItem"
          ]
          Effect   = "Allow"
          Resource = aws_dynamodb_table.deployment_logs_table.arn
        },
      ]
    })
  }
}
resource "aws_iam_role" "log_writer" {
  name = "RoleAssumedByEnv0ToWriteLogsToAgent"
  max_session_duration = local.deployment_task_runtime_timeout_seconds

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.assume_role_policy_statement
  })

  inline_policy {
    name = "RoleAssumedByEnv0ToReadLogsFromAgentPolicy"

    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action   = [
            "dynamodb:DescribeTable",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:GetItem",
            "dynamodb:BatchGetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchWriteItem"
          ]
          Effect   = "Allow"
          Resource = aws_dynamodb_table.deployment_logs_table.arn
        },
      ]
    })
  }
}

