resource "aws_instance" "ec2-bastion-instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    tags = local.common_tags
    user_data = file("/home/vagrant/terraform-scripts/EC2/install-jenkins.sh")
    key_name = aws_key_pair.aws-login.id
    subnet_id = module.vpc.public_subnets[0]
    vpc_security_group_ids = [aws_security_group.access-rules.id]    
}

resource "aws_key_pair" "aws-login" {
    key_name = var.key_name
    public_key = file(var.instance_key_pair)
}

# Create security group for the EC2 bastion host
resource "aws_security_group" "access-rules" {
    name = "${local.name}-public-bastion-sg"
    description = "All SSH and application access"
    tags = local.common_tags
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = var.ingress-ports[0].port
        to_port = var.ingress-ports[0].port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    dynamic "egress" {
        for_each = var.egress-ports
        content {
            from_port = egress.value
            to_port = egress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]  
        }
        
    }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.ec2-bastion-instance.id
  domain = "vpc"
  tags = local.common_tags
  depends_on = [aws_instance.ec2-bastion-instance, module.vpc]
}

resource "null_resource" "copy_ec2_keys"{
    depends_on = [aws_instance.ec2-bastion-instance]
    # Connection block for provisioners to connect to EC2 instance
    connection {
        type = "ssh"
        host = aws_eip.bastion_eip.public_ip
        user = "ubuntu"
        password = ""
        private_key = file("/home/vagrant/.ssh/id_rsa")   
    }
## File provisioner: copies the private key to bastion host
    provisioner "file" {
        source = "/home/vagrant/.ssh/id_rsa"
        destination = "/tmp/id_rsa"
    }
## Remote Exec Provisioner: Using remote-exec provisioner to fix the private key
    provisioner "remote-exec" {
       inline = [
        "sudo chmod 400 /tmp/id_rsa"
       ]  
   }
## Local Exec Provisioner: Using Local VPC to get the VPC ID and store it in a file
    provisioner "local-exec" {
       command = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> vpc-creation-details.txt"
       working_dir = "/home/vagrant/terraform-scripts/development"
       on_failure = continue 
    }
}