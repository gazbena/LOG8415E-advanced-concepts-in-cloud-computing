// AWS specific variables
variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
}

variable "app_name" {
    description = "Name of the application"
    default = "FinalProject"
}

variable "app_version" {
    description = "Version of the API"
    default = "latest"
}

variable "instance_type" {
    description = "Instance type for micro instances"
    type = string
    default = "t2.micro"
}

variable "manager_node_private_ip" {
    description = "Manager node private IP address"
    default = "172.31.78.16"
}

variable "data_node_one_private_ip" {
    description = "First data node private IP address"
    default = "172.31.76.93"
}

variable "data_node_two_private_ip" {
    description = "Second data node private IP address"
    default = "172.31.64.58"
}

variable "data_node_three_private_ip" {
    description = "Third data node private IP address"
    default = "172.31.74.23"
}