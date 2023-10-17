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
resource "aws_security_group" "everywhere" {
    name   = "everywhere"
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

# Key pair
resource "aws_key_pair" "cluster_key" {
    key_name = "cluster-keypair"
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
  
}

resource "local_file" "cluster_keypair" {
    content = tls_private_key.rsa.private_key_pem
    filename = "${path.module}/../../proxy/app/.conf/cluster-keypair.pem"
}

# EC2 Instances
resource "aws_instance" "manager_node" {
    instance_type = "${var.instance_type}"

    key_name = "${aws_key_pair.cluster_key.key_name}"
    private_ip = "${var.manager_node_private_ip}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = templatefile("${path.module}/user_data/manager_userdata.sh", {
        manager_private_ip = "${var.manager_node_private_ip}",
        datanode_one_private_ip = "${var.data_node_one_private_ip}",
        datanode_two_private_ip = "${var.data_node_two_private_ip}",
        datanode_three_private_ip = "${var.data_node_three_private_ip}",
    })
    ami = "ami-061dbd1209944525c"    
    tags = {
        "Name" = "manager-node"
        "Application" = "${var.app_name}"
        "Version" = "${var.app_version}"
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${tls_private_key.rsa.private_key_pem}"
        host = self.public_ip
    }

    # Allows us to make sure user_data script of EC2 instance has finished running
    # This provisioner also allows us to see the output log without having to connect to the instance
    provisioner "remote-exec" {
        inline = [
            "cloud-init status --wait"
        ]
    }

}

resource "aws_instance" "data_node_one" {
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.cluster_key.key_name}"
    private_ip = "${var.data_node_one_private_ip}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = templatefile("${path.module}/user_data/datanode_userdata.sh", {
        manager_private_ip = "${var.manager_node_private_ip}"
    })

    ami = "ami-061dbd1209944525c"
    tags = {
        "Name" = "data-node-1"
        "Application" = "${var.app_name}"
        "Version" = "${var.app_version}"
    }
}

resource "aws_instance" "data_node_two" {

    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.cluster_key.key_name}"
    private_ip = "${var.data_node_two_private_ip}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = templatefile("${path.module}/user_data/datanode_userdata.sh", {
        manager_private_ip = "${var.manager_node_private_ip}"
    })

    ami = "ami-061dbd1209944525c"    
    tags = {
        "Name" = "data-node-2"
        "Application" = "${var.app_name}"
        "Version" = "${var.app_version}"
    }
}

resource "aws_instance" "data_node_three" {

    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.cluster_key.key_name}"
    private_ip = "${var.data_node_three_private_ip}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = templatefile("${path.module}/user_data/datanode_userdata.sh", {
        manager_private_ip = "${var.manager_node_private_ip}"
    })

    ami = "ami-061dbd1209944525c"    
    tags = {
        "Name" = "data-node-3"
        "Application" = "${var.app_name}"
        "Version" = "${var.app_version}"
    }
}

## Outputs
output "manager_public_ip" {
    description = "The manager node public IP assigned to the instance"
    value       = try(aws_instance.manager_node.public_ip, "")
}

output "data_node_one_public_ip" {
    description = "The first data node public IP assigned to the instance"
    value       = try(aws_instance.data_node_one.public_ip, "")
}

output "data_node_two_public_ip" {
    description = "The second data node public IP assigned to the instance"
    value       = try(aws_instance.data_node_two.public_ip, "")
}

output "data_node_three_public_ip" {
    description = "The third data node public IP assigned to the instance"
    value       = try(aws_instance.data_node_three.public_ip, "")
}

output "sg_id" {
    description = "The security group ID used"
    value = aws_security_group.everywhere.id
}
