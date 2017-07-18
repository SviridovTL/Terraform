variable "vpc_id" { default = "vpc-f370b895" }
variable "region" { default = "us-west-2" }
variable "availability_zone" { default = ["a","b"]}

variable "env" { default = "dev" }
variable "system" { default = "bn" }

variable "is_multi_az" { default = "true" }
##################################################
# WEB input Data
##################################################
variable "web_sn_list" { default = ["10.10.11.0/24","10.10.10.0/24"] }

variable "web_sn_1" { default = "10.10.11.0/24" }
variable "web_az_1" { default = "a" }
variable "web_az1_ip" { default = ["10.10.11.11","10.10.11.12"] }

variable "web_sn_2" { default = "10.10.10.0/24" }
variable "web_az_2" { default = "b" }
variable "web_az2_ip" { default = ["10.10.10.11","10.10.10.12","10.10.10.13"] }
##################################################
# ADM input Data
##################################################
variable "adm_sn_list" { default = ["10.10.40.0/24"] }

variable "adm_sn_1" { default = "10.10.40.0/24" }
variable "adm_az_1" { default = "a" }
variable "adm_az1_ip" { default = ["10.10.40.11"] }
##################################################
# BL input Data
##################################################
variable "bl_sn_list" { default = ["10.10.30.0/24", "10.10.31.0/24"] }

variable "bl_sn_1" { default = "10.10.30.0/24" }
variable "bl_az_1" { default = "a" }
variable "bl_az1_ip" { default = ["10.10.30.11","10.10.30.12"] }

variable "bl_sn_2" { default = "10.10.31.0/24" }
variable "bl_az_2" { default = "b" }
variable "bl_az2_ip" { default = ["10.10.31.11"] }
##################################################
# DB input Data
##################################################
variable "db_sn_list" { default = ["10.10.20.0/24","10.10.21.0/24"] }

variable "db_sn_1" { default = "10.10.20.0/24" }
variable "db_az_1" { default = "a" }
variable "db_az1_ip" { default = ["10.10.20.11","10.10.20.12"] }

variable "db_sn_2" { default = "10.10.21.0/24" }
variable "db_az_2" { default = "b" }
variable "db_az2_ip" { default = ["10.10.21.11","10.10.21.12"] }
##################################################
# DOM input Data
##################################################
variable "dom_sn_list" { default = ["10.10.100.0/24", "10.10.101.0/24"] }

variable "dom_sn_1" { default = "10.10.20.0/24" }
variable "dom_az_1" { default = "a" }
variable "dom_az1_ip" { default = ["10.10.100.11"] }

variable "dom_sn_2" { default = "10.10.100.0/24" }
variable "dom_az_2" { default = "b" }
variable "dom_az2_ip" { default = ["10.10.100.11"] }
