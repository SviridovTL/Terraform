resource "aws_subnet" "sn_1" {

  count = "${length(var.web_az_1)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.web_sn_1}"
  availability_zone = "${var.region}${var.web_az_1}"

}

resource "aws_subnet" "sn_2" {

  count = "${length(var.web_az_2)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.web_sn_2}"
  availability_zone = "${var.region}${var.web_az_2}"

}
##################################################
#Create Security Groups
##################################################
resource "aws_security_group" "web-sg" {
  name        = "WEB-SecurityGroup"
  description = "Allow WEB inbound traffic"
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

  # ICMP traffic from DOM
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = "${var.dom_sn_list}"
  }

  # All traffic from WEB
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.web_sn_list}"
  }

  # TCP (443) outside
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks =["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-${var.system}-web-sg"
  }
}
#################################################
resource "aws_security_group" "web-lb-sg" {
  name        = "WEB-LB-SecurityGroup"
  description = "Allow WEB-LB inbound traffic"
  vpc_id = "${var.vpc_id}"

  # TCP (443) outside
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-${var.system}-web-lb-sg"
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

resource "aws_instance" "web_az_1" {

  count = "${length(var.web_az1_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.web_az_1}"
  subnet_id = "${aws_subnet.sn_1.id}"
  private_ip = "${element(var.web_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-web-%01d", count.index + 1)}${var.web_az_1}"
  }
}

# #################################################
# #Create Instances
# ##################################################
resource "aws_instance" "web_az_2" {

  count = "${length(var.web_az2_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.web_az_2}"
  subnet_id = "${aws_subnet.sn_2.id}"
  private_ip = "${element(var.web_az2_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-web-%01d", count.index + 1)}${var.web_az_2}"
  }
}
##################################################
#Create Elastic Load Balancer
##################################################
resource "aws_elb" "web_elb" {
  count = "${length(var.is_multi_az)}"
  name = "web-elb"
  cross_zone_load_balancing = true
  internal = false
  subnets = ["${split(",", var.is_multi_az == 1 ? "${aws_subnet.sn_1.id},${aws_subnet.sn_2.id}" : aws_subnet.sn_1.id)}"]
  security_groups = ["${aws_security_group.web-lb-sg.id}"]
  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    target              = "HTTP:443/"
    interval            = 30
  }

  instances = ["${ split(",",var.is_multi_az == 1 ? join(",", concat(aws_instance.web_az_1.*.id, aws_instance.web_az_2.*.id)) : join(",", aws_instance.web_az_1.*.id))}"]

  tags {
    Name = "${var.env}-${var.system}-web-elb"
  }
}
