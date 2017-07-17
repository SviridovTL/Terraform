provider "aws" {
  access_key = "AKIAJNV4YLI3NGTPUUAA"
  secret_key = "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"
  region     = "${var.region}"
}


module "web_layer_elb" {
  source = "../modules/web-elb"
  vpc_id = "${var.vpc_id}"
  region = "${var.region}"
  availability_zone = "${var.availability_zone}"

  env = "${var.env}"
  system = "${var.system}"

  web_sn_list = "${var.web_sn_list}"
  adm_sn_list = "${var.adm_sn_list}"
  bl_sn_list = "${var.bl_sn_list}"
  dom_sn_list = "${var.dom_sn_list}"

  web_az_1 = "${var.web_az_1}"
  web_az1_ip = "${var.web_az1_ip}"
  web_az_2 = "${var.web_az_2}"
  web_az2_ip = "${var.web_az2_ip}"
}

module "bl_layer" {
  source = "../modules/bl"
  vpc_id = "${var.vpc_id}"
  region = "${var.region}"
  availability_zone = "${var.availability_zone}"

  env = "${var.env}"
  system = "${var.system}"

  web_sn_list = "${var.web_sn_list}"
  adm_sn_list = "${var.adm_sn_list}"
  bl_sn_list = "${var.bl_sn_list}"
  dom_sn_list = "${var.dom_sn_list}"
  db_sn_list = "${var.db_sn_list}"

  bl_az_1 = "${var.bl_az_1}"
  bl_az1_ip = "${var.bl_az1_ip}"
  bl_az_2 = "${var.bl_az_2}"
  bl_az2_ip = "${var.bl_az2_ip}"
}

module "db_layer" {
  source = "../modules/db"
  vpc_id = "${var.vpc_id}"
  region = "${var.region}"
  availability_zone = "${var.availability_zone}"

  env = "${var.env}"
  system = "${var.system}"

  web_sn_list = "${var.web_sn_list}"
  adm_sn_list = "${var.adm_sn_list}"
  bl_sn_list = "${var.bl_sn_list}"
  dom_sn_list = "${var.dom_sn_list}"
  db_sn_list = "${var.db_sn_list}"

  db_az_1 = "${var.db_az_1}"
  db_az1_ip = "${var.db_az1_ip}"
  db_az_2 = "${var.db_az_2}"
  db_az2_ip = "${var.db_az2_ip}"
}

module "dom_layer" {
  source = "../modules/dom"
  vpc_id = "${var.vpc_id}"
  region = "${var.region}"
  availability_zone = "${var.availability_zone}"

  env = "${var.env}"
  system = "${var.system}"

  web_sn_list = "${var.web_sn_list}"
  adm_sn_list = "${var.adm_sn_list}"
  bl_sn_list = "${var.bl_sn_list}"
  dom_sn_list = "${var.dom_sn_list}"
  db_sn_list = "${var.db_sn_list}"

  dom_az_1 = "${var.dom_az_1}"
  dom_az1_ip = "${var.dom_az1_ip}"
  dom_az_2 = "${var.dom_az_2}"
  dom_az2_ip = "${var.dom_az2_ip}"
}

module "adm_layer" {
  source = "../modules/adm"
  vpc_id = "${var.vpc_id}"
  region = "${var.region}"
  availability_zone = "${var.availability_zone}"

  env = "${var.env}"
  system = "${var.system}"

  web_sn_list = "${var.web_sn_list}"
  adm_sn_list = "${var.adm_sn_list}"
  bl_sn_list = "${var.bl_sn_list}"
  dom_sn_list = "${var.dom_sn_list}"
  db_sn_list = "${var.db_sn_list}"

  adm_az_1 = "${var.adm_az_1}"
  adm_az1_ip = "${var.adm_az1_ip}"
}

# module "web_layer_alb" {
#   source = "../modules/web-alb"
#   vpc_id = "${var.vpc_id}"
#   region = "${var.region}"
#   availability_zone = "${var.availability_zone}"
#
#   env = "${var.env}"
#   system = "${var.system}"
#
#   web_sn_list = "${var.web_sn_list}"
#   adm_sn_list = "${var.adm_sn_list}"
#   bl_sn_list = "${var.bl_sn_list}"
#   dom_sn_list = "${var.dom_sn_list}"
#
#   web_az_1 = "${var.web_az_1}"
#   web_az1_ip = "${var.web_az1_ip}"
#   web_az_2 = "${var.web_az_2}"
#   web_az2_ip = "${var.web_az2_ip}"
# }


# module "web_layer_asg" {
#   source = "../modules/web-asg"
#   vpc_id = "${var.vpc_id}"
#   region = "${var.region}"
#   availability_zone = "${var.availability_zone}"
#
#   env = "${var.env}"
#   system = "${var.system}"
#
#   web_sn_list = "${var.web_sn_list}"
#   adm_sn_list = "${var.adm_sn_list}"
#   bl_sn_list = "${var.bl_sn_list}"
#   dom_sn_list = "${var.adm_sn_list}"
#
#   web_az1_ip = "${var.web_az1_ip}"
#   web_az2_ip = "${var.web_az2_ip}"
# }
