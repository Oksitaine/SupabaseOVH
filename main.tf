#################################
# PROVIDER AND CONNECT
#################################

terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "1.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}

provider "ovh" {
  endpoint           = var.ovh_keys.endpoint
  application_key    = var.ovh_keys.application_key
  application_secret = var.ovh_keys.application_secret
  consumer_key       = var.ovh_keys.consumer_key
}


#################################
# OVH KUBERNETES CLUSTER ( FOR FRONTEND )
#################################

# Create cluster without nodepool
resource "ovh_cloud_project_kube" "frontend" {
  service_name  = var.service_public_cloud
  name          = var.cluster_frontend.cluster.name
  region        = var.cluster_frontend.cluster.region
  version       = var.cluster_frontend.cluster.version
  update_policy = var.cluster_frontend.cluster.update_policy
}

resource "ovh_cloud_project_kube_nodepool" "frontend_nodepool" {
  service_name  = var.service_public_cloud
  kube_id       = ovh_cloud_project_kube.frontend.id
  name          = var.cluster_frontend.nodepool.name
  flavor_name   = var.cluster_frontend.nodepool.flavor_name
  desired_nodes = var.cluster_frontend.nodepool.desired_nodes
  anti_affinity = var.cluster_frontend.nodepool.anti_affinity

  depends_on = [
    ovh_cloud_project_kube.frontend
  ]
}


resource "local_file" "kubeconfig_file" {
  content  = ovh_cloud_project_kube.frontend.kubeconfig
  filename = "${path.module}/kubeconfig.yml"

  depends_on = [
    ovh_cloud_project_kube.frontend
  ]
}

resource "null_resource" "run_kubernetes_after_instance" {
  provisioner "local-exec" {
    command = var.kubernetes_start_script
  }

  triggers = {
    kubeconfig_file = local_file.kubeconfig_file.content
  }

  depends_on = [
    ovh_cloud_project_kube_nodepool.frontend_nodepool,
    local_file.kubeconfig_file
  ]
}


#################################
# OVH S3 OBJECT STORAGE ( FOR SUPABASE )
#################################


resource "ovh_cloud_project_user" "user" {
  service_name = var.service_public_cloud
  description  = "Terraform user for s3 access"
  role_names   = [
    "objectstore_operator"
  ]

  depends_on = [
    null_resource.run_kubernetes_after_instance
  ]
}

resource "ovh_cloud_project_user_s3_credential" "my_s3_credentials" {
  service_name = ovh_cloud_project_user.user.service_name
  user_id      = ovh_cloud_project_user.user.id

  depends_on = [
    ovh_cloud_project_user.user
  ]
}

resource "null_resource" "ovh_s3" {
    depends_on = [
        ovh_cloud_project_user_s3_credential.my_s3_credentials
    ]

  # Le trigger ci-dessous force la ré-exécution de la commande si l'une des variables change.
  triggers = {
    project_id           = var.service_public_cloud
    region               = var.s3_storage.region
    oauth_token          = var.ovh_keys.api_ovh
    storage_name         = var.s3_storage.name
  }

  provisioner "local-exec" {
    command = <<EOT
            curl -X POST "https://eu.api.ovh.com/v1/cloud/project/${var.service_public_cloud}/region/${var.s3_storage.region}/storage" \
            -H "accept: application/json" \
            -H "authorization: Bearer ${var.ovh_keys.api_ovh}" \
            -H "content-type: application/json" \
            -d '{"name":"${var.s3_storage.name}"}'
            EOT
  }
}

# WARNING NOTE
# This storage is with the "LOCAL ZONE" specification
# OVH automatically associate the storage with all new user, so don't need do to this
#
# For another s3 storage, we need to do this (1 AZ-Region for exemple)


#################################
# OVH VM INSTANCE ( FOR SUPABASE )
#################################

# TODO : This is come from the s3 storage
# It's will be used in the supabase project to create the s3 bucket
locals {
  s3_access_key = ovh_cloud_project_user_s3_credential.my_s3_credentials.access_key_id
  s3_secret_key = ovh_cloud_project_user_s3_credential.my_s3_credentials.secret_access_key
}


# Create fake ssh key for the vm instance only for the API OVH REQUIREMENT
resource "null_resource" "create_ssh_key" {
    depends_on = [
        null_resource.ovh_s3 
    ]

  # Le trigger ci-dessous force la ré-exécution de la commande si l'une des variables change.
  triggers = {
    project_id           = var.service_public_cloud
    ssh_key_name         = var.supabase_self_host.ssh_key
    ssh_key_public       = var.supabase_self_host.ssh_key_public
  }

  provisioner "local-exec" {
    command = <<EOT
            curl -X POST "https://eu.api.ovh.com/v1/cloud/project/${var.service_public_cloud}/sshkey" \
            -H "accept: application/json" \
            -H "authorization: Bearer ${var.ovh_keys.api_ovh}" \
            -H "content-type: application/json" \
            -d '{"name":"${var.supabase_self_host.ssh_key}","publicKey":"${var.supabase_self_host.ssh_key_public}"}'
            EOT
  }
}


resource "ovh_cloud_project_instance" "supabase_vm" {
    service_name = var.service_public_cloud
    name = var.supabase_self_host.name
    region = var.supabase_self_host.region
    billing_period = var.supabase_self_host.billing_period
    flavor {
        flavor_id = var.supabase_self_host.flavor_id
    }
    boot_from {
        image_id = var.supabase_self_host.image_id
    }
    network {
        public = var.supabase_self_host.network_public
    }
    ssh_key {
        name = var.supabase_self_host.ssh_key
    }
    user_data = file(var.supabase_self_host.user_data)
}

locals {
  ipv4_address = [for item in ovh_cloud_project_instance.supabase_vm.addresses : item if item.version == 4][0].ip
  ipv6_address = [for item in ovh_cloud_project_instance.supabase_vm.addresses : item if item.version == 6][0].ip
}


resource "local_file" "env_file" {
  depends_on = [
    ovh_cloud_project_instance.supabase_vm
  ]

  content = templatefile("${path.module}/env.tmpl", { env_vars = var.env_vars })
  filename = "${path.module}/.env"

  provisioner "local-exec" {
    command = <<EOF
      IPV4_ADDRESS=${local.ipv4_address}

      sed -i "" "s|SITE_URL=http://localhost:3000|SITE_URL=http://$IPV4_ADDRESS:3000|" ${path.module}/.env
      sed -i "" "s|API_EXTERNAL_URL=http://localhost:8000|API_EXTERNAL_URL=http://$IPV4_ADDRESS:8000|" ${path.module}/.env
      sed -i "" "s|SUPABASE_PUBLIC_URL=http://localhost:8000|SUPABASE_PUBLIC_URL=http://$IPV4_ADDRESS:8000|" ${path.module}/.env

      sed -i "" "s|AWS_ACCESS_KEY_ID=|AWS_ACCESS_KEY_ID=${local.s3_access_key}|" ${path.module}/.env
      sed -i "" "s|AWS_SECRET_ACCESS_KEY=|AWS_SECRET_ACCESS_KEY=${local.s3_secret_key}|" ${path.module}/.env
    EOF
  }
}

locals {
  ansible_command = <<EOF
    ansible-playbook -i ubuntu@${local.ipv4_address}, ${path.module}/ansible.yml \
    -e "docker_username=${var.docker_login.username}" \
    -e "docker_password=${var.docker_login.password}"
  EOF
}

resource "null_resource" "ansible_playbook" {
  depends_on = [
    local_file.env_file
  ]

  triggers = {
    ansible_command = local.ansible_command
    ansible_file = file("${path.module}/ansible.yml")
  }

  provisioner "local-exec" {
    command = local.ansible_command
  }
}