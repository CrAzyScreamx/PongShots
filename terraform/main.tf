

### VPC ###
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    name = var.tag
  }
}

### Subnet ###
resource "aws_subnet" "name" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    name = var.tag
  }
}

### Internet Gateway ###
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = var.tag
  }
}

### Route Table ###
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    name = var.tag
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.name.id
  route_table_id = aws_route_table.main.id
}

### Security Group Rules ###
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = var.tag
  }
}

resource "aws_security_group_rule" "allow-ssh-inbound" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH access"
  type              = "ingress"
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "allow-application-inbound" {
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Application access"
  type              = "ingress"
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "allow-all-outbound" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  type              = "egress"
  security_group_id = aws_security_group.main.id
}


### Load Public Key ###
resource "aws_key_pair" "vm-key" {
  key_name   = "vm-key"
  public_key = file(var.ssh_key_path)
}

### Get AMI for Ubuntu 22.04 ###
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical AMI

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

### Launch VM Instance ###
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vm-key.key_name
  subnet_id              = aws_subnet.name.id
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data_base64 = base64encode(templatefile("./initScripts/cloud-init.sh", {
    docker_compose_yml  = file("./initScripts/docker-compose.yml"),
    watchtower_interval = var.watchtower_interval
  }))
  user_data_replace_on_change = true

  tags = {
    name = var.tag
  }
}
