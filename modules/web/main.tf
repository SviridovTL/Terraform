resource "aws_subnet" "sn_1" {
  #check if we need to create subnet. When 'web_az_*' empty => length = 0
  count = "${length(var.web_az_1)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.web_sn_1}"
  availability_zone = "${var.region}${var.web_az_1}"

  tags {
    Name = "${var.env}-${var.system}-web-sn-${var.web_az_1}"
  }
}

resource "aws_subnet" "sn_2" {
  #check if we need to create web_az_2
  #count = "${var.is_web_az_2_present}"
  count = "${length(var.web_az_2)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.web_sn_2}"
  availability_zone = "${var.region}${var.web_az_2}"

  tags {
    Name = "${var.env}-${var.system}-web-sn-${var.web_az_2}"
  }
}

##################################################
##################################################

resource "aws_security_group" "sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "TCP"
    cidr_blocks = "${var.adm_sn_list}"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = "${var.bl_sn_list}"
  }

  tags {
    Name = "${var.env}-${var.system}-web-sg"
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
##################################################

resource "aws_instance" "web_web_az_1" {

  #multiply to 'var.is_sn_*_present=false will result '0' and resource will not work
  #count = "${length(var.web_az1_ip) * var.is_web_az_1_present}"
  count = "${length(var.web_az1_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.web_az_1}"
  subnet_id = "${aws_subnet.sn_1.id}"
  private_ip = "${element(var.web_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-web-%01d", count.index + 1)}${var.web_az_1}"
  }
}

resource "aws_instance" "web_web_az_2" {

  #multiply to 'var.is_sn_*_present=false will result '0' and resource will not work
  #count = "${length(var.web_az2_ip) * var.is_web_az_2_present}"
  count = "${length(var.web_az2_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.web_az_2}"
  subnet_id = "${aws_subnet.sn_2.id}"
  private_ip = "${element(var.web_az2_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-web-%01d", count.index + 1)}${var.web_az_2}"
  }
}
