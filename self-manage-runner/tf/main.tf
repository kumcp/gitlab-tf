provider "aws" {
  region = "ap-southeast-1"
}

locals {
  instance_type = var.instance_type
  project_name  = var.project_name
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# Create default vpc data source 
data "aws_vpc" "default_vpc" {
  default = true
}

# Get data source as default security group from vpc



data "aws_security_group" "default_sg" {
  vpc_id = data.aws_vpc.default_vpc.id

  name = "default"
}

# Create security group for runner instance which allow port 22 and 80
resource "aws_security_group" "runner_sg" {
  name        = "runner-security-group"
  description = "Security group for GitLab runner"
  vpc_id      = data.aws_vpc.default_vpc.id

  tags = {
    Name = "${local.project_name}-sg"
  }
}
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.runner_sg.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.runner_sg.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.runner_sg.id
}



resource "aws_instance" "runner_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.instance_type
  vpc_security_group_ids = [data.aws_security_group.default_sg.id, aws_security_group.runner_sg.id]


  user_data = <<-EOF
        #!/bin/bash
        # Download the binary for your system
        sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

        # Give it permission to execute
        sudo chmod +x /usr/local/bin/gitlab-runner

        # Create a GitLab Runner user
        sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

        # Install and run as a service
        sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
        sudo gitlab-runner start
        
        gitlab-runner register --non-interactive --url ${var.runner_server} --token ${var.runner_token} \
        --executor ${var.runner_executor} --name ${var.runner_name} --docker-pull-policy always \
        --docker-privileged=false \
        --limit 0

        gitlab-runner run
        EOF

  tags = {
    Name = local.project_name
  }
}

