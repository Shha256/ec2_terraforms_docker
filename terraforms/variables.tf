variable "ami" {
    default = "ami-0b0dcb5067f052a63"  
}

variable "instance_type" {
    default = "t2.micro"
}

variable "key-name" {
    default = "prd01"
}

variable "vpccidr" {
    default = "10.1.0.0/16"
}

variable "subnet_cidr" {
    default = "10.1.1.0/24"
}
variable "region" {
  type        = string
  description = "(Required) AWS Region."
  default     = "us-east-1a"
}




variable "shared_credentials_files" {
  type        = list(string)
  description = "(Required) Shared credentials file for AWS profiles."
  default     = ["~/.aws/credentials"]
}