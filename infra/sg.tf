###############################################################
#  SECURITY GROUPS FOR ALB, ECS FARGATE, AND RDS POSTGRESQL  #
###############################################################

# =======================
# ALB Security Group
# =======================
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      =  aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}


# =======================
# ECS Fargate Security Group
# =======================
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow ALB to ECS and ECS to RDS"
  vpc_id      = aws_vpc.main.id

  # ALB → ECS (port 1337)
  ingress {
    description = "Allow ALB to access Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb_sg.id
    ]
  }

  # ECS outbound traffic allowed (for NAT, RDS, etc.)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
  }
}


# =======================
# RDS Security Group
# =======================
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow ECS to access PostgreSQL"
  vpc_id      =  aws_vpc.main.id

  ingress {
    description = "Allow ECS to connect to Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ecs_sg.id
    ]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}