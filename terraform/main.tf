# ── Custom VPC ──────────────────────────────────────────────────────────────

resource "aws_vpc" "ansible_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "ansible_igw" {
  vpc_id = aws_vpc.ansible_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "ansible_public" {
  count                   = 2
  vpc_id                  = aws_vpc.ansible_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${count.index + 1}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.ansible_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansible_igw.id
  }

  tags = {
    Name = "${var.name_prefix}-default-rt"
  }
}

resource "aws_route_table_association" "ansible_public_rta" {
  count          = 2
  subnet_id      = aws_subnet.ansible_public[count.index].id
  route_table_id = aws_default_route_table.default.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.ansible_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SMTP Submission (Email relay)"
    from_port   = 587
    to_port     = 587
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

# Create an Ubuntu Ansible Master EC2 Instance in the Custom VPC
resource "aws_instance" "ubuntu_ansible_master" {
  ami                    = var.ubuntu_ansible_master_ami_id
  instance_type          = var.ubuntu_ansible_master_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.ansible_public[0].id
  vpc_security_group_ids = [aws_default_security_group.default.id]

  tags = {
    Name = "Ubuntu-Ansible-Master"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}

resource "aws_instance" "ubuntu_ansible_worker" {
  ami                    = var.ubuntu_ansible_worker_ami_id
  instance_type          = var.ubuntu_ansible_worker_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.ansible_public[count.index % 2].id
  vpc_security_group_ids = [aws_default_security_group.default.id]
  count                  = var.ansible_worker_count

  tags = {
    Name        = format("Ubuntu-Ansible-Worker-%02d", count.index + 1)
    Environment = "dev"
  }

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }
}


