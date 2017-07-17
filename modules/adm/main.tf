##################################################
#Create Subnets
##################################################
resource "aws_subnet" "adm" {
  count = "${length(var.adm_sn_list)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.adm_sn_list, count.index)}"
  availability_zone = "${var.region}${element(var.availability_zone, count.index)}"

  tags {
     Name = "${var.env}-${var.system}-adm-sn-${element(var.availability_zone, count.index)}"
  }
}
##################################################
#Create Security Groups
##################################################
resource "aws_security_group" "adm-sg" {
  name        = "ADM-SecurityGroup"
  description = "Allow ADM inbound traffic"
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

  # ALL trafficfrom WEB
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.web_sn_list}"
  }

  tags {
    Name = "${var.env}-${var.system}-adm-sg"
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
#Create Insatnces
##################################################

resource "aws_instance" "adm_az_1" {

  count = "${length(var.adm_az_1)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.adm_az_1}"
  subnet_id = "${aws_subnet.adm.0.id}"
  private_ip = "${element(var.adm_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.adm-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-adm-%01d", count.index + 1)}${var.adm_az_1}"
  }
}
