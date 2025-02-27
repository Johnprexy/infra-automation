variable "do_token" {
  description = "Digital Ocean API Token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of SSH key in Digital Ocean"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "johntodoapp.duckdns.org"
}

variable "droplet_size" {
  description = "Size of the DigitalOcean droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_region" {
  description = "Region for the DigitalOcean droplet"
  type        = string
  default     = "nyc1"
}
