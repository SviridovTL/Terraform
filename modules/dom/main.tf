##################################################
#Create Subnets
##################################################
resource "aws_subnet" "dom" {
  count = "${length(var.dom_sn_list)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.dom_sn_list, count.index)}"
  availability_zone = "${var.region}${element(var.availability_zone, count.index)}"

  tags {
     Name = "${var.env}-${var.system}-dom-sn-${element(var.availability_zone, count.index)}"
  }
}
##################################################
#Create Security Groups
##################################################
resource "aws_security_group" "dom-sg" {
  name        = "DOM-SecurityGroup"
  description = "Allow DOM inbound traffic"
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

  # UDP (53) traffic from WEB
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "UDP"
    cidr_blocks = "${var.web_sn_list}"
  }

  # TCP (53) traffic from WEB
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "TCP"
    cidr_blocks = "${var.web_sn_list}"
  }

  # ICMP traffic from WEB
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = "${var.web_sn_list}"
  }

  tags {
    Name = "${var.env}-${var.system}-dom-sg"
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

resource "aws_instance" "dom_az_1" {

  count = "${length(var.dom_az_1)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.dom_az_1}"
  subnet_id = "${aws_subnet.dom.0.id}"
  private_ip = "${element(var.dom_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.dom-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-dom-%01d", count.index + 1)}${var.dom_az_1}"
  }
}
#################################################
#Create Insatnces
##################################################
resource "aws_instance" "dom_az_2" {

  count = "${length(var.dom_az_2)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.dom_az_2}"
  subnet_id = "${aws_subnet.dom.1.id}"
  private_ip = "${element(var.dom_az2_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.dom-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-dom-%01d", count.index + 1)}${var.dom_az_2}"
  }
}
