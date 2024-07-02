variable "region" {
    default = "us-east-1"
    type = string
}

# AWS EC2 instance type
variable "instance_type" {
    description = "EC2 Instance Type"
    type = string
    default = "t2.micro"
}

# Key pair Variables
variable "instance_key_pair" {
    description = "AWS EC2 Key pair that need to be associated with AWS instance"
    type = string
    default = "/home/vagrant/.ssh/id_rsa.pub"
}

variable "key_name" {
    default = "testvpc_loginkey"
    type = string
}

variable "ingress-ports" {
    type = list(object({
        description = string
        port = number
    }))
    default = [
        {
            description = "Allow SSH access"
            port = 22
    },
    {
            description = "Allow application access"
            port = 80
    }
    ]
}

variable "egress-ports" {
    default = [80,443]
    type = set(number)
}