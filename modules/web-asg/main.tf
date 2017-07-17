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
##################################################
resource "aws_elb" "web_elb" {
  name = "web-elb"
  cross_zone_load_balancing = true
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
##################################################
resource "aws_launch_configuration" "web_launch_conf" {
    #name = "web-launch-conf"
    image_id = "${data.aws_ami.ubuntu.id}"
    security_groups = ["${aws_security_group.web-sg.id}"]
    instance_type = "t2.micro"
    name_prefix = "${var.env}-${var.system}-web-"
    #associate_public_ip_address = true
}
##################################################
##################################################
resource "aws_autoscaling_group" "web_asg" {
  availability_zones = ["${aws_subnet.web.*.availability_zone}"]
  name = "web-asg"
  min_size = 3
  max_size = 5
  desired_capacity = 4
  health_check_grace_period = 60
  health_check_type = "ELB"
  force_delete = false
  launch_configuration = "${aws_launch_configuration.web_launch_conf.name}"
  load_balancers = ["${aws_elb.web_elb.id}"]
  vpc_zone_identifier = ["${aws_subnet.web.*.id}"]
  lifecycle {
     create_before_destroy = true
   }
  #vpc_zone_identifier = ["${element(split(",", var.private_subnet_ids), 0)}", "${element(split(",", var.private_subnet_ids), 1)}"]
}
##################################################
#Assign EIP to instances
##################################################
# resource "aws_eip" "eip_web" {
#    count = "${length(var.web_az1_ip)}"
#    instance = "${element(aws_instance.web_web_az_1.*.id, count.index)}"
# }
