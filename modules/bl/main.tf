##################################################
#Create Subnets
##################################################
resource "aws_subnet" "bl" {
  count = "${length(var.bl_sn_list)}"

  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.bl_sn_list, count.index)}"
  availability_zone = "${var.region}${element(var.availability_zone, count.index)}"

  tags {
     Name = "${var.env}-${var.system}-bl-sn-${element(var.availability_zone, count.index)}"
  }
}
##################################################
#Create Security Groups
##################################################
resource "aws_security_group" "bl-sg" {
  name        = "BL-SecurityGroup"
  description = "Allow BL inbound traffic"
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

  # All traffic from DOM
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.dom_sn_list}"
  }

  # All traffic from DB
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.db_sn_list}"
  }
  # 443 TCP traffic from WEB
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = "${var.web_sn_list}"
  }

  tags {
    Name = "${var.env}-${var.system}-bl-sg"
  }
}
##################################################
##################################################
resource "aws_security_group" "bl-lb-sg" {
  name        = "BL-LB-SecurityGroup"
  description = "Allow BL-LB inbound traffic"
  vpc_id = "${var.vpc_id}"

  # TCP (443) outside
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = "${var.web_sn_list}"
  }

  tags {
    Name = "${var.env}-${var.system}-bl-lb-sg"
  }
}
##################################################
#Create Elastic Load Balancer
##################################################
resource "aws_elb" "bl_elb" {
  name = "bl-elb"
  cross_zone_load_balancing = true
  subnets = ["${aws_subnet.bl.*.id}"]
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
    Name = "${var.env}-${var.system}-bl-elb"
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

resource "aws_instance" "bl_az_1" {

  count = "${length(var.bl_az1_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.bl_az_1}"
  subnet_id = "${aws_subnet.bl.0.id}"
  private_ip = "${element(var.bl_az1_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.bl-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-bl-%01d", count.index + 1)}${var.bl_az_1}"
  }
}

##################################################
#Assign instances to ELB
##################################################
resource "aws_elb_attachment" "elb_bl_az_1" {
  elb      = "${aws_elb.bl_elb.id}"
  count = "${length(var.bl_az1_ip)}"
  instance = "${element(aws_instance.bl_az_1.*.id, count.index)}"
}
#################################################
#Create Instances
##################################################
resource "aws_instance" "bl_az_2" {

  count = "${length(var.bl_az2_ip)}"

  ami  = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  availability_zone = "${var.region}${var.bl_az_2}"
  subnet_id = "${aws_subnet.bl.1.id}"
  private_ip = "${element(var.bl_az2_ip, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.bl-sg.id}"]

  tags {
    Name = "${format("${var.env}-${var.system}-bl-%01d", count.index + 1)}${var.bl_az_1}"
  }
}
##################################################
#Assign instances to ELB
##################################################
resource "aws_elb_attachment" "elb_bl_az_2" {
  elb      = "${aws_elb.bl_elb.id}"
  count = "${length(var.bl_az2_ip)}"
  instance = "${element(aws_instance.bl_az_2.*.id, count.index)}"
}
