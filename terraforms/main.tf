## arquivo Main que configura recursos usando o Terraform, seguindo o curso de Daniel Gill na Udemy e vídeos no YouTube. Especificamos a versão do Terraform, o provedor de nuvem e a região. Utilizamos credenciais armazenadas no diretório local 'aws' da máquina por razões de segurança e praticidade

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  profile = "default"
  
shared_credentials_files = ["~/.aws/credentials"]

}
##Criamos uma instância EC2 usando a AMI Linux padrão e o tipo T2 Micro (disponível no nível gratuito) no arquivo de variáveis. Utilizamos a variável 'key' para indicar um ambiente de produção.
resource "aws_instance" "ec2" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key-name
  
   vpc_security_group_ids = ["${aws_security_group.rtp03-sg.id}"]
   subnet_id = "${aws_subnet.rtp03-public_subent_01.id}"
}
##Configuramos um grupo de segurança  habilitando o trafego na porta 22 e 80
resource "aws_security_group" "rtp03-sg" {
    name = "rtp03-sg"
    vpc_id = "${aws_vpc.rtp03-vpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ssh-sg"

    }

}

##Criamos uma VPC (Virtual Private Cloud) e usamos a variável 'vpcidr' para definir o bloco de endereços CIDR da rede de forma flexível e personalizada
resource "aws_vpc" "rtp03-vpc" {
    cidr_block = var.vpccidr
    tags = {
      Name = "rpt03-vpc"
    }
  
}

## Criamos uma sub-rede pública na zona disponível 'us-east-1a' usando uma variável para configurar o bloco CIDR

resource "aws_subnet" "rtp03-public_subent_01" {
    vpc_id = "${aws_vpc.rtp03-vpc.id}"
    cidr_block = var.subnet_cidr
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "rtp03-public_subent_01"
    }
  
}

resource "aws_internet_gateway" "rtp03-igw" {
    vpc_id = "${aws_vpc.rtp03-vpc.id}"
    tags = {
      Name = "rtp03-igw"
    }
}

##Criamos a atbelas de rotas permitindo o trafego 
resource "aws_route_table" "rtp03-public-rt" {
    vpc_id = "${aws_vpc.rtp03-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.rtp03-igw.id}"
    }
    tags = {
      Name = "rtp03-public-rt"
    }
}



resource "aws_route_table_association" "rtp03-rta-public-subent-1" {
    subnet_id = "${aws_subnet.rtp03-public_subent_01.id}"
    route_table_id = "${aws_route_table.rtp03-public-rt.id}"
  
}