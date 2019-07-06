variable "region" {
  type    = "string"
  default = "ams1"
}

variable "type" {
  default = "DEV1-S"
}

variable "enable_ipv6" {
  default     = true
  description = "Enabling IPv6"
}

variable "dynamic_ip" {
  default     = true
  description = "Enabling public_ip"
}

variable "acme_domain" {
  default     = ""
  description = "Default domain for certbot"
}

variable "acme_email" {
  default     = ""
  description = "Default email for certbot"
}

variable "worker_tcp_ports" {
  default = [22, 80, 443]
}

variable "archs" {
  default = {
    DEV1-S   = "x86_64"
    DEV1-M   = "x86_64"
    DEV1-L   = "x86_64"
    DEV1-XL  = "x86_64"
  }
}
