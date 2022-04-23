variable "api_key" {
    type    = string
    description = "apikey"
    default = "59a80bbbf11aa10001cf7413/5fb6a7847564612d32046328/6069be3b7564612d32c53983"
}

variable "secretkey" {
    type = string
    description = "Secretkey location"
    default = "private_key_gdnovais_zrh.pem" 
}

variable "endpoint" {
    type = string
    description = "api endpoint url"
    default = "https://www.intersight.com"
}

variable "organization" {
    type = string
    description = "organisation moid"
    default = "609c52976972652d33b61d71"
}

variable "prefix" {
    type = string
    description = "policies prefix"
    default = "tf"
}

variable "intersight_tag" {
    type= map
    description = "value"
    default = {
        key = "createdby"
        value = "g9ais"
    }
}

variable "servername" {
    type = string
    description = "server name to be deployed"
    default = "server000"
}

variable "fcconnectivity" {
    type = bool
    description = "either has fc adapters or not!"
    default = false
}

