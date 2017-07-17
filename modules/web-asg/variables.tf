variable "vpc_id" {}
variable "region" {}
variable "availability_zone" { type = "list" }

variable "env" {}
variable "system" {}

variable "web_sn_list" { type = "list" }
variable "adm_sn_list" { type = "list" }
variable "bl_sn_list" { type = "list" }
variable "dom_sn_list" { type = "list" }


variable "web_az1_ip" { type = "list" }
variable "web_az2_ip" { type = "list" }
