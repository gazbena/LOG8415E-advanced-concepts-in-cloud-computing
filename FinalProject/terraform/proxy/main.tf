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

# EC2 instance
resource "aws_instance" "proxy" {

    instance_type = "${var.instance_type}"
    key_name = "cluster-keypair"

    vpc_security_group_ids = [
        "${var.sg_id}",
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = file("${path.module}/user_data/proxy_user_data.sh")

    ami = "ami-061dbd1209944525c"    
    tags = {
        "Name" = "proxy"
        "Application" = "FinalProject"
        "Version" = "latest"
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("${path.module}/../../proxy/app/.conf/cluster-keypair.pem")
        host = self.public_ip
    }

    # Provisioning api app to instance
    provisioner "file" {
      source      = "${path.module}/user_data/proxy_app.zip"
      destination = "/tmp/proxy_app.zip"
    }

    # Allows us to make sure user_data script of EC2 instance has finished running
    provisioner "remote-exec" {
        inline = [
            "cloud-init status --wait"
        ]
    }
}

# Output
output "public_ip" {
    description = "Proxy public IP"
    value = aws_instance.proxy.public_ip
}
