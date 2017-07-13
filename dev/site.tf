provider "aws" {
  access_key = "AKIAJT4GM4WMQNGO3IRQ"
  secret_key = "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"
  region     = "${var.region}"
}


module "web_layer" {

  source = "../modules/web"
  vpc_id = "${var.vpc_id}"
  region = "${var.region}"

  web_sn_1 = "${var.web_sn_1}"
  web_az_1 = "${var.web_az_1}"
  web_az1_ip = "${var.web_az1_ip}"

  web_sn_2 = "${var.web_sn_2}"
  web_az_2 = "${var.web_az_2}"
  web_az2_ip = "${var.web_az2_ip}"

  adm_sn_list = "${var.adm_sn_list}"
  bl_sn_list = "${var.bl_sn_list}"

  env = "${var.env}"
  system = "${var.system}"
}
