---
title: "Implementing CD Pipeline for Static Website"
date: 2020-07-05T10:42:08-07:00
draft: false
tags: ["circleci", "devops", "terraform", "hugo"]
featured: false
description: "Are you still deploying your static webiste by hand? Learn how to use CircleCi and Git in order to automate the workflow."
---
One day I decided to create a backup of all my `dev.to` posts. Programmers are lazy, so I wanted to do as little work as possible, and wanted the final result to look as nice as possible (or at least nicer than Markdown reader on GitHub). 

Final requirements for the project were the following:

- Fully static (cheap/free to host)
- Markdown support (copy and paste existing material)
- Continuous deployment (automation is good)
- Easy to maintain (easy is good)

Based on the requirements, I decided on this simple workflow:

- The website is build with [Hugo](https://gohugo.io)
- The source code is stored in [BitBucket](https://bitbucket.org/)
- The deployment is done via [CircleCi](https://circleci.com/)
- The website is deployed and hosted in [AWS S3](https://aws.amazon.com/s3/) 
- The AWS resources are managed by [Terraform](https://www.terraform.io/)

## Step 1: Generate a New Hugo Website

This step is straightforward, but also was the most time-consuming. I had to manually copy all of my posts into new Hugo project. If you are following my steps, Hugo has a great [Getting Started guide](https://gohugo.io/getting-started/quick-start/).

## Step 2: Create the AWS Resources

I will be using Terraform to simplify this step. If you are not familiar with the tool, I have an [introductory level article](https://dev.to/aakatev/deploy-ec2-instance-in-minutes-with-terraform-ip2) to get you going. For more detailed introduction, refer to [Terraform learning center](https://learn.hashicorp.com/terraform). Also, you can always [create resources by hand](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html).

```hcl
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

variable "static_bucket_name" {
  type    = string
  default = "aakatev-blog"
}

resource "aws_s3_bucket" "static_bucket" {
  bucket = var.static_bucket_name
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
                  "arn:aws:s3:::${var.static_bucket_name}/*"
              ]
          }
      ]
    }
  EOT
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
                  "arn:aws:s3:::${var.static_bucket_name}",
                  "arn:aws:s3:::${var.static_bucket_name}/*"
              ]
          }
      ]
    }
  EOT
}

output "circle_ci_access_key" {
  value = aws_iam_access_key.circle_ci_access_key.id
}

output "circle_ci_access_key_secret" {
  value = aws_iam_access_key.circle_ci_access_key.secret
}
```

If everything went well, your output for this step should look like this:

```bash
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

circle_ci_access_key = SOME_AWS_KEY_ID
circle_ci_access_key_secret = SOME_AWS_KEY_SECRET
```

These keys will need to be exported as environmental variables during CircleCI build.

**Terraform will store the keys in its [state](https://www.terraform.io/docs/state/index.html) as a plaintext. You are responsible for keeping their secrecy.**

## Step 3: Store the Source Code

I will be using BitBucket as my version control, but GitHub will do the trick too. AFAIK there are no differences in CircleCI integration with both.

Create a file `.circleci/config.yml` with the following content:

```yml
version: 2
jobs:
  build:
    docker:
      - image: cibuilds/hugo:0.73
    working_directory: /home/circleci/hugo
    environment:
      HUGO_DIR: /home/circleci/hugo
      S3_BUCKET: aakatev-blog
    steps:
      - checkout
      - run: git submodule sync && git submodule update --init
      - run:
          name: install AWS CLI (first install pip, the Python package manager)
          command: |
            sudo apt install python-pip
            pip install awscli
      - run: HUGO_ENV=production hugo -v -s $HUGO_DIR

      - run:
          name: test our generated HTML files
          command: |
            htmlproofer $HUGO_DIR/public --allow-hash-href --check-html \
            --empty-alt-ignore --disable-external
      - deploy:
          name: deploy to AWS
          command: |
            if [ "${CIRCLE_BRANCH}" = "master" ]; then
              aws s3 sync $HUGO_DIR/public \
              s3://$S3_BUCKET/ --delete
            else
              echo "Not master branch, dry run only"
            fi
```

## Step 4: Configure the CircleCI pipeline

Besides `config.yml` CircleCI needs access keys, in order to have administrator access to the S3 bucket. Visit your **Project Settings** section:

![CircleCI configuration](https://dev-to-uploads.s3.amazonaws.com/i/iev9cf64ykko3b97c61q.png)

For more information refer to CircleCI docs on [environmental variables](https://circleci.com/docs/2.0/env-vars/). 

## Step 5: Enjoy the Result

At this point, the website is available for public, and you can view mine [here](https://artem.lol).

In case, you followed, and want to see yours, the pattern for S3 domains is `http://<bucket_name>.s3-website-<region>-<zone>.amazonaws.com`.

Since my website is a backup, I didn't really care about domain name, nor some other features a real blog should have. That said, it would be a logical future additions to the project.