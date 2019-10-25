# Tags input
variable "input_tags" {
    default      = ""
    description  = "Tags to identify the customer (comma seperated)"
    type         = string
}

# Location of the pem file
variable "pem_file" {
	default 	=	""
    description = "Location of pem file"
    type = string
}

# oraclesid
variable "oraclesid"{
default = ""
description = "tag name of the customer (oraclesid)"
type = "string"
}
variable "tag_owners" {
        type            =       "string"
        default         =       "745078641086"
}

variable "tag_type" {
        type            =       "string"
        default         =       "gp2"
}
variable "tag_size" {
        type            =       "string"
        default         =       "16384"
}
variable "tag_az" {
        type            =       "string"
        default         =       "us-east-1a"
}

variable "tag_term" {
        type            =       "string"
        default         =       "true"
}

