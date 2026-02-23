resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "strapi_cluster_capacity" {
  cluster_name = aws_ecs_cluster.strapi_cluster.name

  capacity_providers = ["FARGATE_SPOT"]

    default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
 }

}

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecsExecutionRole.arn
  task_role_arn      = aws_iam_role.ecs_fargate_taskRole.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.app_image
      essential = true

      environment = [
        { name = "HOST",                   value = "0.0.0.0" },
        { name = "PORT",                   value = "1337" },
        { name = "NODE_ENV",               value = "production" },

        { name = "DATABASE_CLIENT",        value = "postgres" },
        { name = "DATABASE_HOST",          value = aws_db_instance.postgres.address },
        { name = "DATABASE_PORT",          value = "5432" },
        { name = "DATABASE_NAME",          value = "strapidb" },
        { name = "DATABASE_USERNAME",      value = "adminsiri" },
        { name = "DATABASE_PASSWORD",      value = "Password123!" },
        { name = "DATABASE_SSL",           value = "true" },
        { name = "DATABASE_SSL_REJECT_UNAUTHORIZED",     value = "false" },
        
        { name = "URL",                    value = "http://${aws_lb.alb.dns_name}" },

        { name = "APP_KEYS",               value = "key1,key2,key3,key4" },
        { name = "API_TOKEN_SALT",         value = "yoursalt" },
        { name = "ADMIN_JWT_SECRET",       value = "youradminsecret" },
        { name = "JWT_SECRET",             value = "yourjwtsecret" }
      ],

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ],

      
    }
  ])
}


resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
 }


  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
     


load_balancer {
  target_group_arn = aws_lb_target_group.tg.arn
  container_name   = "strapi"
  container_port   = 1337 
}

depends_on = [
  aws_lb_listener.alb_listener ,
  aws_ecs_cluster_capacity_providers.strapi_cluster_capacity
]

}