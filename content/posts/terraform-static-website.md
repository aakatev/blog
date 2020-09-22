---
title: "Static Website Infrastructure with Terraform"
date: 2020-07-18T10:42:08-07:00
draft: false
tags: ["terrafrom", "aws", "devops", "webdev", "iac"]
featured: true
description: "Terraform is awesome. Learn how to bootstrap a static website infrastructure with CDN on AWS."
---

Deploying a static website is one of the easiest task a web developer faces. There is a number of solutions allowing to complete the deployment process in a matter of few minutes, and several buttons clicks. What a wonderful world we live in! However, this approach has one huge limitation. You don't really own the underlying infrastructure. I claim that there is a way you can both do the deployment fast, and own the underlying infrastructure. You can Terraform it!

This article is not a guide, but an artifact documenting my journey on the way to deploy a personal blog and its underlying infrastructure. You might want to check out [the beginning of the journey](https://dev.to/aakatev/implementing-cd-pipeline-for-static-website-3p6l), where I share my Continuous Deployment setup.

TLDR, I have a static Hugo website hosted in S3 bucket. Now it is time to make it production ready!

Let's define the final specs:

- Domain name (using AWS Route53)
- Distributed by CDN (using AWS Cloudfront)
- SSL/TLS support (using AWS Certificate Manager)

## Step 1: Get a Domain Name

This step is pretty much manual. AWS has a detailed instruction on [getting a domain](https://aws.amazon.com/getting-started/hands-on/get-a-domain/). Note, that AWS automatically creates a hosted zone, and name serve (NS) record for you. It is important that you have an existing valid hosted zone before proceeding to the next step. If you need more information on how to create a new hosted zone, or configure the NS record, please refer to [this part](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/GetInfoAboutHostedZone.html) of the AWS guide.

## Step 2: Provision the AWS Resources

This article assumes you already know some Terraform. If you are not familiar with it, I have an [introductory level article](https://dev.to/aakatev/deploy-ec2-instance-in-minutes-with-terraform-ip2) to get you going. For more detailed introduction, refer to the [Terraform learning center](https://learn.hashicorp.com/terraform). 

I will be using Terraform Cloud in order to store my state. Read more about this configuration on the [Terraform website](https://learn.hashicorp.com/terraform/state/tfc_migration). You can also modify the templates to configure Terraform to use the local backend.

**Templates Folder Structure**

```sh
├── main.tf
├── outputs.tf
├── variables.auto.tfvars
└── variables.tf
```

**main.tf**

This is the complete template I use for my website setup. It not only provisions the AWS resources (S3, Route53, Cloudfront, and etc), but also credentials for the CircleCI deployment. If you are not interesting in setting up the CI/CD pipeline, you can exclude IAM User and the Policy from the template.

**Remember, Terraform will store the keys in its [state](https://www.terraform.io/docs/state/index.html) as a plaintext. You are responsible for keeping their secrecy.**

```hcl
terraform {
  required_version = "~> 0.12.25"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "example-organization"

    workspaces {
      name = "example-workspace"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

data "aws_route53_zone" "static_bucket_zone" {
  name = var.domain_name
}

resource "aws_s3_bucket" "static_bucket" {
  bucket = var.domain_name
  acl    = "public-read"

  force_destroy = true

  website {
    index_document = "index.html"
  }

  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "PublicReadGetObject",
              "Effect": "Allow",
              "Principal": "*",
              "Action": [
                  "s3:GetObject"
              ],
              "Resource": [
                  "arn:aws:s3:::${var.domain_name}/*"
              ]
          }
      ]
    }
  EOT
}

resource "aws_acm_certificate" "static_bucket_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    terraform = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "static_bucket_record" {
  zone_id = data.aws_route53_zone.static_bucket_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_bucket_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_bucket_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "static_bucket_certificate" {
  certificate_arn = aws_acm_certificate.static_bucket_certificate.arn
  timeouts {
    create = "20m"
  }
}

resource "aws_cloudfront_distribution" "static_bucket_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_s3_bucket.static_bucket.website_endpoint
    origin_id   = var.domain_name
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.domain_name
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [var.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.static_bucket_certificate.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_iam_user" "circle_ci_user" {
  name = "circle-ci"
}

resource "aws_iam_access_key" "circle_ci_access_key" {
  user = aws_iam_user.circle_ci_user.name
}

resource "aws_iam_user_policy" "circle_ci_policy" {
  name = "circle-ci-policy"
  user = aws_iam_user.circle_ci_user.name

  policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "s3:*",
              "Resource": [
                  "arn:aws:s3:::${var.domain_name}",
                  "arn:aws:s3:::${var.domain_name}/*"
              ]
          }
      ]
    }
  EOT
}

```

**variables.tf**

```hcl
variable "domain_name" {
  type        = string
  description = "Website root domain name"
}

variable "region" {
  type        = string
  description = "AWS region to create resources"
}
```

**outputs.tf**

Again, if you don't use CI/CD, this part can be safely ignored.

```hcl
output "circle_ci_access_key" {
  value = aws_iam_access_key.circle_ci_access_key.id
}

output "circle_ci_access_key_secret" {
  value = aws_iam_access_key.circle_ci_access_key.secret
}
```

**variables.auto.tf**

Note, that adding auto suffix to a Terraform variables definition will make the file load automatically. 

```hcl
domain_name  = "example.com"
region       = "us-east-1"
```

## Step 3: Enjoy the Result

After the provisioning is successfully completed, it may still take few minutes for the Cloudfront, and Route53 configurations to fully sync. If you used the AWS CDN services with your domain name before, it is a good idea to [invalidate cache](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html). 

---

You can find my final result at [artem.lol](https://artem.lol). If you have any questions, or run into issues trying to provision the infrastructure using my template please let me know in comments on my [dev.to](https://dev.to/aakatev/static-website-infrastructure-with-terraform-jgi) blog! 