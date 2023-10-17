terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
      }
    }
}

provider "aws" {
    region = "${var.aws_region}"
}


## Security Group
resource "aws_security_group" "standalone_sg" {
    name   = "standalone_sg"
    vpc_id = "${data.aws_vpc.default.id}"

    ingress {
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
    }
    egress {
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
    }

}

resource "aws_key_pair" "cluster_key" {
    key_name = "standalone-keypair"
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
  
}

resource "local_file" "cluster_keypair" {
    content = tls_private_key.rsa.private_key_pem
    filename = "${path.module}/standalone-keypair.pem"
}


## EC2 instance
resource "aws_instance" "standalone" {

    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.cluster_key.key_name}"

    vpc_security_group_ids = [
        aws_security_group.standalone_sg.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = file("${path.module}/user_data/user-data.sh")

    ami = "ami-061dbd1209944525c"    
    tags = {
        "Name" = "standalone"
        "Application" = "FinalProject"
        "Version" = "latest"
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${tls_private_key.rsa.private_key_pem}"
        host = self.public_ip
    }

    # Allows us to make sure user_data script of EC2 instance has finished running
    provisioner "remote-exec" {
        inline = [
            "cloud-init status --wait"
        ]
    }
}

output "standalone_public_ip" {
    description = "The public IP assigned to the instance"
    value       = try(aws_instance.standalone.public_ip, "")
}