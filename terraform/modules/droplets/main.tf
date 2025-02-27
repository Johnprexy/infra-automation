terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  description = "Digital Ocean API Token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of SSH key in Digital Ocean"
  type        = string
}



variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "johntodoapp.duckdns.org"  # Updated to use DuckDNS domain
}

variable "droplet_size" {
  description = "Droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_region" {
  description = "Droplet region"
  type        = string
  default     = "nyc1"
}

# Get SSH key ID by name
data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

# Create a new Droplet
resource "digitalocean_droplet" "app_server" {
  image     = "ubuntu-20-04-x64"
  name      = "todo-app-server"
  region    = var.droplet_region
  size      = var.droplet_size
  ssh_keys  = [data.digitalocean_ssh_key.ssh_key.id]
  
  # Use user data to set up initial access
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl git
  EOF
}

# Removed DigitalOcean DNS resources since you are using DuckDNS

# Create firewall
resource "digitalocean_firewall" "web" {
  name = "todo-app-firewall"

  droplet_ids = [digitalocean_droplet.app_server.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "droplet_ip" {
  description = "Public IP of the Droplet"
  value       = digitalocean_droplet.app_server.ipv4_address
}
