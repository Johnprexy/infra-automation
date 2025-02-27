terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a Droplet
module "droplet" {
  source               = "../../modules/droplets" # ✅ Updated path
  do_token             = var.do_token
  ssh_key_name         = var.ssh_key_name
  ssh_private_key_path = var.ssh_private_key_path # ✅ Added missing variable
  domain_name          = var.domain_name
  droplet_size         = var.droplet_size
  droplet_region       = var.droplet_region
}

# Generate inventory file for Ansible
resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      ip_address = module.droplet.droplet_ip
      ssh_key    = var.ssh_private_key_path
    }
  )
  filename = "${path.module}/../../../ansible/inventory.ini"

  provisioner "local-exec" {
    command = "cd ../../../ansible && ansible-playbook -i inventory.ini deploy.yml"
  }

  depends_on = [module.droplet]
}
