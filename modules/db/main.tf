##################################################
#Create Subnets
##################################################
resource "aws_subnet" "db" {
  count = "${length(var.db_sn_list)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.db_sn_list, count.index)}"
  availability_zone = "${var.region}${element(var.availability_zone, count.index)}"

  tags {
     Name = "${var.env}-${var.system}-db-sn-${element(var.availability_zone, count.index)}"
  }
}
##################################################
#Create Security Groups
##################################################
resource "aws_security_group" "db-sg" {
  name        = "DB-SecurityGroup"
  description = "Allow DB inbound traffic"
  vpc_id = "${var.vpc_id}"

  # All traffic from ADM
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.adm_sn_list}"
  }

  # All traffic from BL
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.bl_sn_list}"
  }

  # ALL traffic from DOM
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.dom_sn_list}"
  }

  # ALL traffic from DB
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.db_sn_list}"
  }

  tags {
    Name = "${var.env}-${var.system}-db-sg"
  }
}
##################################################
##################################################
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
##################################################
#Create Instances
##################################################

resource "aws_instance" "db_az_1" {

  count = "${length(var.db_az1_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.db_az_1}"
  subnet_id = "${aws_subnet.db.0.id}"
  private_ip = "${element(var.db_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
  ebs_block_device {
        device_name = "xvdb"
        volume_type = "standard"
        volume_size = 100
    }
  tags {
    Name = "${format("${var.env}-${var.system}-db-%01d", count.index + 1)}${var.db_az_1}"
  }
}
#################################################
#Create Instances
##################################################
resource "aws_instance" "db_az_2" {

  count = "${length(var.db_az2_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.db_az_2}"
  subnet_id = "${aws_subnet.db.1.id}"
  private_ip = "${element(var.db_az2_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
  ebs_block_device {
        device_name = "/dev/sda1"
        volume_type = "standard"
        delete_on_termination = true
        volume_size = 150
    }
  tags {
    Name = "${format("${var.env}-${var.system}-db-%01d", count.index + 1)}${var.db_az_2}"
  }
}
