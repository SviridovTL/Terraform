##################################################
#Create Subnets
##################################################
resource "aws_subnet" "web" {
  #check if we need to create subnet. When 'web_az_*' empty => length = 0
  count = "${length(var.web_sn_list)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.web_sn_list, count.index)}"
  availability_zone = "${var.region}${element(var.availability_zone, count.index)}"

  tags {
     Name = "${var.env}-${var.system}-web-sn-${element(var.availability_zone, count.index)}"
  }
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
##################################################
##################################################
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
#Create Elastic Load Balancer
##################################################
resource "aws_elb" "web_elb" {
  name = "web-elb"
  cross_zone_load_balancing = true
  internal = false
  subnets = ["${aws_subnet.web.*.id}"]
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

  tags {
    Name = "${var.env}-${var.system}-web-elb"
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

resource "aws_instance" "web_web_az_1" {

  #multiply to 'var.is_sn_*_present=false will result '0' and resource will not work
  #count = "${length(var.web_az1_ip) * var.is_web_az_1_present}"
  count = "${length(var.web_az1_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.web_az_1}"
  #availability_zone = "${aws_instance.web_web_az_1.*.availability_zone}"
  subnet_id = "${aws_subnet.web.0.id}"
  private_ip = "${element(var.web_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-web-%01d", count.index + 1)}${var.web_az_1}"
  }
}
##################################################
#Assign EIP to instances
##################################################
resource "aws_eip" "eip_web_az_1" {
   count = "${length(var.web_az1_ip)}"
   instance = "${element(aws_instance.web_web_az_1.*.id, count.index)}"
}
##################################################
#Assign instances to ELB
##################################################
resource "aws_elb_attachment" "elb_web_az_1" {
  elb      = "${aws_elb.web_elb.id}"
  count = "${length(var.web_az1_ip)}"
  instance = "${element(aws_instance.web_web_az_1.*.id, count.index)}"
}
#################################################
#Create Instances
##################################################
resource "aws_instance" "web_web_az_2" {

  #multiply to 'var.is_sn_*_present=false will result '0' and resource will not work
  #count = "${length(var.web_az1_ip) * var.is_web_az_1_present}"
  count = "${length(var.web_az2_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.web_az_2}"
  subnet_id = "${aws_subnet.web.1.id}"
  private_ip = "${element(var.web_az2_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-web-%01d", count.index + 1)}${var.web_az_2}"
  }
}
##################################################
#Assign EIP to instances
##################################################
resource "aws_eip" "eip_web_az_2" {
   count = "${length(var.web_az2_ip)}"
   instance = "${element(aws_instance.web_web_az_2.*.id, count.index)}"
}
##################################################
#Assign instances to ELB
##################################################
resource "aws_elb_attachment" "elb_web_az_2" {
  elb      = "${aws_elb.web_elb.id}"
  count = "${length(var.web_az2_ip)}"
  instance = "${element(aws_instance.web_web_az_2.*.id, count.index)}"
}
