# ---------------------------------------------------
# Code Deploy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group
# ---------------------------------------------------

# アプリケーション
resource "aws_codedeploy_app" "ecs_app" {
  name = "${var.project}-${var.env}-codedeploy-application"
  # コンピューティングタイプ
  compute_platform = "ECS"
}

# resource "aws_codedeploy_deployment_config" "ecs_deployment_config" {
#   deployment_config_name = "${var.project}-codedeploy-deployment-config"
#   compute_platform = "ECS"

#   traffic_routing_config {
#     type = "AllAtOnce"
#   }
# }

# デプロイグループ
resource "aws_codedeploy_deployment_group" "ecs_deployment_group" {
  # アプリケーション
  app_name = aws_codedeploy_app.ecs_app.name
  # デプロイグループ名
  deployment_group_name = "${var.project}-${var.env}-codedeploy-deployment-group"

  # デプロイ設定/デプロイ設定（グリーンへの切り替えを一度に行う）
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  # サービスロール
  service_role_arn = aws_iam_role.codedeploy_role.arn

  # ロールバック
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    # トラフィックの再ルーティング（Greenへの切り替え）
    deployment_ready_option {
      # すぐに再ルーティング
      #action_on_timeout = "CONTINUE_DEPLOYMENT"

      # 10分待ってから再ルーティング（その間にテスト用リスナーで Green を確認できる）
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 10
    }

    # ブルーグリーンデプロイ完了後の旧環境（Blue）の扱いに関する設定
    terminate_blue_instances_on_deployment_success {
      # デプロイ成功後、5分間待機してから Blue 環境を削除する
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # 環境設定
  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.prod_traffic_route_listener_arn]
      }

      # テスト用リスナー
      test_traffic_route {
        listener_arns = [var.test_traffic_route_listener_arn]
      }

      target_group {
        name = var.target_group1_name
      }

      target_group {
        name = var.target_group2_name
      }

    }
  }
}

# サービスロール
resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployECSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
