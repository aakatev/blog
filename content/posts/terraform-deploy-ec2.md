---
title: "Deploy EC2 Instance in Minutes with Terraform"
date: 2020-04-19T08:42:08-07:00
draft: false
tags: ["devops", "iac", "terraform", "introduction"]
featured: false
description: "Terraform is awesome. Learn how to create an EC2 instance on AWS in minutes."
---

Everyone using AWS knows that navigating the console could be a major pain. Luckily there is a number of tools aiming to simplify this burden. One of them is Terraform by HashiCorp. Today, I want to introduce the tool, and show how to deploy EC2 instance on aws in minutes.

## Overview

Firstly, what is Terraform? In short, it is an IaC (Infrastructure as Code) tool easing a process of delivering software. It allows you to define your infrastructure in a similar way you write your applications. With this approach you can apply some of the application development practices to you deployment process. For example, using a control system to keep track of code changes, and easily track bugs.

One major difference between Terraform code, and most mainstream programming languages, is that the first one encourage a declarative style, rather than procedural. Programmer specifies some desired state, and the software is going to figure out how to get their. While this approach is not great for application development, it is proven reliable in IaC world. 

A classic example, one day John created 10 EC2 instances. Few weeks after, he realized that 10 is barely enough to cover his needs, and 5 more EC2 instances had to be added to his pool. In procedural approach, John would have to go and create 5 more instances. On the other hand, declarative tool allows John to specify how many EC2 instances he needs in total. In other words, John won't have to worry about his current state of the infrastructure, as Terraform, or any other declarative tool, is taking care of it! 

## Installation 

Terraform supports most major OS. I will not spend much time on this section, since [official documentation](https://learn.hashicorp.com/terraform/getting-started/install.html) covers it pretty extensively. 

## Configure AWS CLI

For this tutorial, you will need to have AWS CLI installed. The official guide could be found [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

After AWS CLI is installed, you need to configure it! First, create a new [access keys](https://console.aws.amazon.com/iam/home?#/security_credentials). Now, in your terminal run `aws configure`, and enter your credentials. It will allow Terraform AWS provider to access AWS API.

## Create EC2

It is time for the fun part! Create a new directory. Inside, create a file with arbitrary name, but `tf` extension, and the following content:

```hcl
provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu"
  public_key = file("key.pub")
}

resource "aws_security_group" "ubuntu" {
  name        = "allow-ssh"
  description = "Allow SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}


resource "aws_instance" "ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-03ba3948f6c37a4b0"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key")
    host        = self.public_ip
  }

}

resource "aws_eip" "ubuntu" {
  vpc      = true
  instance = aws_instance.ubuntu.id
}
```
The best part about Terraform, people familiar with AWS, can guess all the created resources by looking at the file! We are going to create EC2 T2 Micro instance with AMI 03ba3948f6c37a4b0, new security group allowing inbound traffic on port 22, for SSH, new SSH key pair, and associate, and allocate Elastic IP for our instance. 

Notice, that I am using a local key pair. The keys should be located in the same folder as your Terraform file, and be named `keys.pub`, and `keys`. You can change your key location value, or even [hardcode the key](https://www.terraform.io/docs/providers/aws/r/key_pair.html) directly in your program. 

I advice you to generate a new key, specifically for this tutorial! On Linux machine it could be done using `ssh-keygen`:

```bash
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/dev/.ssh/id_rsa): key
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in key.
Your public key has been saved in key.pub.
The key fingerprint is:
SHA256:K+5CJqeyyfx/Wlwg0yb9P3mJd+nqyQu/cHq8bLO+0J4 dev@pop-os
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|      o          |
|     + =         |
|      = o        |
|        So       |
|  . + . ... + . .|
|   *  .o.  O.* o |
|+.. ...o    #==  |
|o=...==    .=EO. |
+----[SHA256]-----+
```

Don't forget to setup correct permission to the keys:

```bash
chmod 400 key*
```

Once previous steps completed, you can finally provision your VM! First, initialize Terraform project, and pull all the necessary dependencies:

```bash
terraform init
```

You normally only need to do it once for each project, but the command is idempotent, which means it is safe to run it again. Now that the project is ready, let's provision our EC2:

```bash
terraform apply 
```

Type `yes`, and within 2 minutes your AWS resources will be allocated! If you go to your AWS console, you will see that EC2 instances is up and running. You can SSH to it using the key we created earlier!

## Changes and Termination

As I said earlier, Terraform is declarative. In case you need to make any changes to your EC2, simply change your Terraform file, and run `terraform apply` again! Once you decided that resources no longer needed, you can run `terraform destroy`, and terminate them. As easy as that!

## Version Control

If you are planning to use Git as version control for your Terraform projects, I recommend to create `.gitignore` looking the following way:

```
.terraform
*.tfstate
*.tfstate.backup
```

As for tracking your state, there are various ways of dealing with the issue, but they all are out of scope of this tutorial. If you are interested in this question, I recommend Chapter 3 of [Terraform: Up & Running](https://www.terraformupandrunning.com/) by [Yevgeniy Brikman](https://github.com/brikis98). This book is one of the best sources on Terraform, and extensively covers most of the best practices around the tool!

## Conclusion

I showed you how to create an EC2 instance on AWS using Terraform. Although the first time it may take you some time to install the tool, and configure AWS provider, the provision itself take on average less than 2 minutes! The best part, Terraform is compatible with most major Cloud providers, like AWS, GCD, Azure, and Digital Ocean. It has a great community support, and expandable using modules.

Finally, the source and brief instructions for this tutorial is available on [GitHub](https://github.com/aakatev/terraform-aws). 
