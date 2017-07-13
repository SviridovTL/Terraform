variable "vpc_id" { default = "vpc-c64f82a0" }
variable "region" { default = "us-west-2" }


variable "web_az_1" { default = "a" }
variable "web_sn_1" { default = "10.10.88.0/24" }
variable "web_az1_ip" { default = ["10.10.88.11", "10.10.88.12", "10.10.88.13"] }


variable "web_az_2" { default = "b" }
variable "web_sn_2" { default = "10.10.89.0/24" }
variable "web_az2_ip" { default = ["10.10.89.11"] }

variable "adm_sn_list" { default = ["10.10.85.0/24", "10.10.86.0/24"] }
variable "bl_sn_list" { default = ["10.10.66.0/24", "10.10.67.0/24"] }


variable "env" { default = "dev" }
variable "system" { default = "bn" }
