

# Terraform AWS Networking Module

This Terraform module creates a VPC, subnets, route tables, an internet gateway, and a security group with customizable settings for a specific environment.

## Features

- **VPC Creation**: A customizable VPC with CIDR block and environment-specific tags.
- **Subnets**: Public subnets based on input settings.
- **Route Tables**: Public route table with an internet gateway.
- **Security Group**: Allows SSH, HTTP, HTTPS ingress traffic, and all outbound traffic.

## File Structure

```
terraform-aws-networking/
├── main-igw.tf        # Internet Gateway
├── main-route.tf      # Route Table and Associations
├── main-sg.tf         # Security Group
├── main-subnet.tf     # Public Subnets
├── main-vpc.tf        # VPC
├── outputs.tf         # Output Variables
├── README.md          # Documentation
├── variables.tf       # Input Variables
└── version.tf         # Terraform Version and Providers
```

## Usage Example

Here’s how you can use this module in your Terraform project:

```hcl
module "networking" {
  source = "./path/to/terraform-aws-networking"

  env               = "prod"
  vpc_cidr_block    = "10.0.0.0/16"

  subnet_settings = {
    public_subnet_1 = {
      public_ip         = true
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-west-1a"
    },
    public_subnet_2 = {
      public_ip         = true
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-west-1b"
    }
  }

  sg_settings = {
    ssh_ingress = {
      type        = "ingress"
      description = "Allows SSH access"
      port        = 22
      protocol    = "tcp"
    },
    http_ingress = {
      type        = "ingress"
      description = "Allows HTTP traffic"
      port        = 80
      protocol    = "tcp"
    },
    https_ingress = {
      type        = "ingress"
      description = "Allows HTTPS traffic"
      port        = 443
      protocol    = "tcp"
    },
    all_egress = {
      type        = "egress"
      description = "Allows all outbound traffic"
      port        = 0
      protocol    = "-1"
    }
  }
}
```

### Applying the configuration

```bash
terraform init
terraform apply
```

## Input Variables

| Name             | Description                                 | Type                                                                                  | Default | Required |
|------------------|---------------------------------------------|---------------------------------------------------------------------------------------|---------|----------|
| `env`            | Environment for this project                | `string`                                                                              |         | yes      |
| `vpc_cidr_block` | CIDR block for the VPC                      | `string`                                                                              |         | yes      |
| `subnet_settings`| Details of the subnets, including CIDR and AZ | `map(object({ public_ip = bool, cidr_block = string, availability_zone = string }))` |         | yes      |
| `sg_settings`    | Security group settings for ingress/egress  | `map(object({ type = string, description = string, port = number, protocol = string }))`|  -      | no       |

## Output Variables

| Name               | Description                              |
|--------------------|------------------------------------------|
| `public_subnet_ids` | Map of public subnet IDs                 |
| `security_group_id` | List containing the Security Group ID    |

## Explanation of Components

### VPC

The module creates a VPC with a customizable CIDR block. The name is tagged with the `env` variable to distinguish between environments.

```hcl
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.env}-main-vpc"
  }
}
```

### Subnets

Public subnets are created using the `subnet_settings` map, which allows configuring CIDR blocks and availability zones.

```hcl
resource "aws_subnet" "public_subnet" {
  for_each = var.subnet_settings
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = each.value.public_ip
}
```

### Route Tables

A public route table is created and associated with the subnets, allowing public access via the internet gateway.

```hcl
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
```

### Security Group

The security group allows customizable ingress and egress rules using dynamic blocks. By default, it allows SSH, HTTP, HTTPS ingress, and all outbound traffic.

```hcl
resource "aws_security_group" "allow_ssh_http_https" {
  vpc_id = aws_vpc.main_vpc.id
  dynamic "ingress" {
    for_each = var.sg_settings
    content {
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

## Versioning

This module requires Terraform `>= 1.0` and AWS Provider `~> 5.56`.

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.56"
    }
  }
}
```

