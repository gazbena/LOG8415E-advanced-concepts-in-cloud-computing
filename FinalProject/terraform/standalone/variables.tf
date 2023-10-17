variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type = map(string)
    default = {
        "Name" = "FinalProject"
        "Application" = "FinalProject"
        "Version" = "latest"
    }
}

variable "instance_type" {
    description = "Instance type for micro instances"
    type = string
    default = "t2.micro"
}