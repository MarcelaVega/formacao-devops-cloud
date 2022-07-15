## DESAFIO 02 - FORMAÇÃO DEVOPS CLOUD

Desafio: A empresa 'Marisa Store' possui um site que constantemente fica inoperante por estar hospedado em infraestrutura local na sede da empresa,  Martin que é CTO da empresa não está contente com isso pois está recebendo diversas reclamações de clientes que não conseguem finalizar suas compras fazendo a empresa perder **muito** dinheiro, por indicação de um amigo ele decidiu lhe contratar para montar uma nova infraestrutura em nuvem para tentar resolver esse problema.

Em conversa com a equipe de TI da 'Marisa Store' as informações que lhe passaram foram estas:

 - O site é em Wordpress com banco de dados MySQL;
 - Atualmente ele está rodando em uma maquina com 2 vCPU e 2GB RAM;
 - Atualmente a empresa ainda não possui um certificado HTTPS;
 - O domínio da empresa (marisastore.tf) está atualmente hospedado em um servidor local.

As exigências de Martin são:

 - A infraestrutura deve ser desenvolvida como código com Terraform;
 - A infraestrutura deve ser de fácil portabilidade;
 - A infraestrutura deve ser criada na nuvem da AWS.

Com base nas informações acima desenvolva a sua versão da infraestrutura conforme pedido de Martin usando dos conhecimentos e boas práticas aprendidas até agora, insira seu projeto IaC em um repositório GIT e compartilhe com seus colegas no grupo da comunidade.


############################################################################################
## New Version for this case:
A empresa CT Eventos possui um site em WordPress que atualmente está hospedado em uma VPS. 
A configuração do servidor que atualmente hospeda o site é de 2 vCPU e 8 GB de memória. 
Este site possui anúncios vinculados na qual recebe uma grande quantidade de acessos diários, em torno de 1.000 acessos. 
Um desses anúncios é sobre a divulgação de um grande evento de empreendedorismo que irá acontecer em maio. 
Em seu último anúncio sobre a divulgação de um evento do mesmo tipo, a empresa ficou com o seu site indisponível durante 4 horas, tendo um impacto aproximado de R$ 15.000,00. Na ocasião, a quantidade de acessos por dia girava em torno de 10.000 a 12.000. 
Para isso, a CT Eventos precisa de vocês uma solução para manter seu site funcionando sem indisponibilidade. 
Ela prevê um aumento de acessos em seu site, pois o evento terá participação de uma empresa renomada. 
Estima-se receber algo em torno de 20.000 mil acessos a mais por dia. A campanha durará 20 dias, porém após o encerramento do evento, o site precisará continuar com a mesma disponibilidade.

##############################################################

## DISCLAIMER
This project was created only for didactic purposes within the limitations of the AWS free tier*, such as exercise in Terraform. 
Some improvements will still be implemented.
*** WAF in diagram not included by IaC.
*** DNS zone generates costs!
*** For full implementation, it is necessary to install and configure the plugin "WP Offload Media Lite" in WordPress to enable the use of the S3 bucket and delivery by Cloudfront
For more information watch this video: https://youtu.be/k7LGqoa2nbo

## ############# INSTALLATION INSTRUCTIONS #################

Clone this repo and create a new file for variables how the following: (variables.tf)
After runs: terraform init
           terraform plan
           terraform apply

## ---------------------- VARIABLES.tf CONTENT ---------------------------
variable "provider-param" {
  description = "Provider parameters"  
  type    = map
  default = {
    "region" = "put-your-aws-region"
    "profile" = "default" # For other, change the value.
  }
}

variable "project-name" {
  type        = string
  description = "Project name for tagging resources"
  default     = "put-your-project-name"

}

# Discontinued for Auto Scaling, use this for create ec2-instances extra Auto Scaling
variable "instance_count" {
  description = "The number of instances in ecs-cluster extra auto scaling"
  type = string
  default = "0"
}

variable "env" {
  description = "Environments list by region"
  type = map
  default = {
  "us-east-1" = "prod"
  "sa-east-1" = "dev"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Avaibility zones for VPC by region"
  type = map
  default = {
  "us-east-1" = ["us-east-1a", "us-east-1b"]
  "sa-east-1" = ["sa-east-1a", "sa-east-1b"]
  }
}

variable "vpc_private_subnets" {
  description = "Private  subnets for VPC"
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type = list
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "ecs-image" {
  description = "ECS container image"
  type = string
  default = "docker.io/library/wordpress:latest"
}

variable "ecs-desired-count" {
  description = "Desired count for running tasks "
  type = string
  default = "2"
}

## # For import the key-par using SSH key rsa.pub
variable "ec2-key" {
  description = "EC2 key pair for SSH connection"
  type = map
  default = {
    "name" = "Put the key name"
    "key"  = "Put your ssh-rsa key"
  }
}

# The key-pair must be created previously in AWS Console
variable "ec2-key" {
  description = "Key name previously created in AWS Console"
  type        = string
  default     = "Key-name in AWS Console"
}

variable "db-param" {
  description = "Database creation parameters"
  type = map
  default = {
    "user" = "yourUser"
    "port" = "3306"
    # the password is random created, check terraform.tfstate after creation
  }
}

# EC2 Auto Scaling Group, change "max" values for scaling
variable "scaling-group-param" {
  description = "Auto Scaling group creation parameters"
  type        = map(any)
  default = {
    "max"           = "2"
    "min"           = "2"
    "desired"       = "2"
    "ami_id"        = "See data.aws_ami.amazon_ecs.id don't change here"
    "instance_type" = "t2.micro"
  }
}

# ECS Auto Scaling, change the values by your desire
variable "scaling-ecs-param" {
  description = "App Auto Scaling parameters"
  type        = map(any)
  default = {
    "max"     = "6"
    "min"     = "4"
    "desired" = "4"
  }
}

# The DNS zone must be created previously in AWS Console
variable "dns" {
  description = "DNS records parameters"
  type        = map(any)
  default = {
    "zone_id" = "Your Zone ID"
    "name"    = "Your DNS name for registry creation"
  }
}