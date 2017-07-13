variable "vpc_id" {}
variable "region" {}

#variable "is_web_az_1_present" {}
variable "web_sn_1" {}
variable "web_az_1" {}
variable "web_az1_ip" { type = "list" }

#variable "is_web_az_2_present" {}
variable "web_sn_2" {}
variable "web_az_2" {}
variable "web_az2_ip" { type = "list" }

variable "adm_sn_list" { type = "list" }
variable "bl_sn_list" { type = "list" }

variable "env" {}
variable "system" {}
