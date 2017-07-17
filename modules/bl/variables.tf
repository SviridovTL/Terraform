variable "vpc_id" {}
variable "region" {}
variable "availability_zone" { type = "list" }

variable "env" {}
variable "system" {}

variable "web_sn_list" { type = "list" }
variable "adm_sn_list" { type = "list" }
variable "bl_sn_list" { type = "list" }
variable "dom_sn_list" { type = "list" }
variable "db_sn_list" { type = "list" }

variable "bl_az_1" {}
variable "bl_az_2" {}
variable "bl_az1_ip" { type = "list" }
variable "bl_az2_ip" { type = "list" }
