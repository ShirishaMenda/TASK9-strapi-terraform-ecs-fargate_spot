# ---------------------------------------------------------
# ECS Task Role (Application Role)
# ---------------------------------------------------------
resource "aws_iam_role" "ecs_fargate_taskRole" {
  name               = "ecs_fargate_taskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Permissions for the App running inside ECS
resource "aws_iam_role_policy" "ecs_fargate_taskRole_policy" {
  role = aws_iam_role.ecs_fargate_taskRole.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:*",
          "ssm:GetParameter",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------
# ECS Execution Role
# ---------------------------------------------------------
resource "aws_iam_role" "ecsExecutionRole" {
  name               = "ecsExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume.json
}

data "aws_iam_policy_document" "ecs_execution_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Managed Policy: AmazonECSTaskExecutionRolePolicy
resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecsExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}