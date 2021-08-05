data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # AWS
}

data "aws_subnet" "public" {
  filter {
    name = "tag:Name"
    values = [
      "public-0"
    ]
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "bastion-ssh"
  vpc_id      = data.aws_subnet.public.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.eks_authorized_ips
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  revoke_rules_on_delete = true
}

resource "aws_network_interface" "bastion" {
  subnet_id       = data.aws_subnet.public.id
  security_groups = [aws_security_group.bastion.id]

  tags = {
    Name = "public-0"
  }
}

# Do we rather want to generate the key in tf and store in the paramater
data "aws_ssm_parameter" "bastion_public_key" {
  name = "bastion-public-ssh-key"
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion"
  public_key = data.aws_ssm_parameter.bastion_public_key.value
}

data "aws_iam_role" "eks_admin" {
  name = "eks-admin"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion-eks"
  role = data.aws_iam_role.eks_admin.name
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.aws_linux.id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  key_name = aws_key_pair.bastion.key_name

  #user_data = file("${path.module}/file/startup.sh")
  user_data = templatefile("${path.module}/templates/startup.sh.tpl", {
    region  = data.aws_region.current.name,
    account = data.aws_caller_identity.current.account_id,
  })

  iam_instance_profile = aws_iam_instance_profile.bastion.id
}
