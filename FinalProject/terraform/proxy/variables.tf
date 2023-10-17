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
    default = "t2.large"
}

variable "sg_id"{
    description = "Cluster security group ID"
    type = string
}