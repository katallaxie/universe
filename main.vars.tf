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

variable "traefik_email" {
  default     = "admin@acme"
  description = "Default email address to use for ACME"
}

variable "traefik_domain" {
  default     = "acme"
  description = "Default domain for traefik"
}

variable "worker_tcp_ports" {
  default = [22, 443]
}

variable "archs" {
  default = {
    DEV1-S   = "x86_64"
    DEV1-M   = "x86_64"
    DEV1-L   = "x86_64"
    DEV1-XL  = "x86_64"
  }
}
