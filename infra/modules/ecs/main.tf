# ---------------------------------------------------
# ECS
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# ---------------------------------------------------

# クラスター
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project}-${var.env}-cluster"
}

# タスク定義
resource "aws_ecs_task_definition" "app_task_definition" {
  family                   = "${var.project}-${var.env}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  #task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu    = "256"
  memory = "512"

  # コンテナ
  container_definitions = jsonencode([
    {
      name      = "${var.project}-${var.env}-container"
      image     = "your-docker-image-url"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

# タスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# セキュリティグループ（サービスのネットワーキングで）
resource "aws_security_group" "ecs_sg" {
  name   = "${var.project}-${var.env}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id] # ALBからの通信を許可
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# サービス
# 再apply時、タスク定義が変わったと判定されエラーになるのを防ぐ
# https://zenn.dev/2357gi/scraps/a1c98f05d6e446

# 最新のタスク定義を取得
#data "aws_ecs_task_definition" "latest" {
#  task_definition = "${var.project}-task-definition"
#}

resource "aws_ecs_service" "service" {
  name            = "${var.project}-${var.env}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task_definition.arn
  #task_definition = data.aws_ecs_task_definition.latest.arn  # 最新のタスク定義 ARN を使用

  scheduling_strategy = "REPLICA"
  desired_count       = 2
  launch_type         = "FARGATE"

  # デプロイオプション/デプロイタイプ
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # ロードバランサ
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project}-${var.env}-container"
    container_port   = 8080
  }

  # ネットワーキング
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  # タスク定義とロードバランサの変更は無視
  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}
