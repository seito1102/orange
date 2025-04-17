# --------------------------------------------------------------------
# S3 バケットの定義（CloudFront 経由でアクセスするためのバケット）
# --------------------------------------------------------------------
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-cloudfront-bucket-tokyo"

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# --------------------------------------------------------------------
# CloudFront OAC (Origin Access Control)
# --------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "frontend-oac"
  description                       = "OAC for Frontend S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 バケットポリシーの設定（CloudFront OAI のみ S3 へのアクセスを許可）
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"  # CloudFrontのサービスを指定
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.my_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.my_distribution.arn  # CloudFrontのディストリビューションARNを指定
          }
        }
      }
    ]
  })
}

# CloudFront ディストリビューションの定義（S3 バケットをオリジンとする）
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.my_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  enabled             = true  # ディストリビューションを有効化
  is_ipv6_enabled     = false  # IPv6 を有効化
  comment             = "CloudFront Distribution for S3 bucket in Tokyo region"
  default_root_object = "index.html" # ルートにアクセスした際のデフォルトファイル

  # デフォルトのキャッシュ動作設定（GET/HEAD のみ許可し、HTTPS にリダイレクト）
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.my_bucket.id

    forwarded_values {
      query_string = false # クエリパラメータをキャッシュのキーに含めない

      cookies {
        forward = "none" # クッキーを転送しない
      }
    }

    viewer_protocol_policy = "redirect-to-https" # HTTP を HTTPS にリダイレクト
  }

  # 地理的制限の設定（制限なし）
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 料金クラスの設定（安価なリージョンのみ使用）
  price_class = "PriceClass_100"

  # CloudFront の SSL 証明書設定（デフォルトの CloudFront 証明書を使用）
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "MyCloudFrontDistribution"
    Environment = "Production"
  }
}
