#################################
# GLOBAL VARIABLES
#################################

variable "ovh_keys" {
    type = map(string)
    description = "Oauth token for ovh api"
    default = {
        # TODO : This one is for connect to your ovh account with terraform
        # Follow this link for get the api key : https://www.ovh.com/auth/api/createToken?GET=/*&POST=/*&PUT=/*&DELETE=/*
        endpoint = "ovh-eu"
        application_key = "your_ovh_application_key"
        application_secret = "your_ovh_application_secret"
        consumer_key = "your_ovh_consumer_key"
    
        # TODO : This one is for create a s3 container cause with 1.6.0 version of ovh provider, 
        # we can't create a s3 container with the provider
        # Follow this link for get the api key : https://eu.api.ovh.com/console/?section=%2Fcloud&branch=v1#auth
        api_ovh = "your_ovh_api_token"
    }
}

variable "service_public_cloud" {
    type = string
    description = "The ID for detect the good project in the public cloud account in OVH"
    default = "your_public_cloud_project_id"
}



#################################
# KUBERNETES CLUSTER VARIABLES
#################################

variable "cluster_frontend" {
    type = map(any)
    description = "The ID for detect the good project in the public cloud account in OVH"
    default = {
        ###################
        # KUBERNETES CLUSTER
        # More info : https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube
        ###################
        cluster = {
            name = "frontend"
            region = "your_cluster_region"
            version = "your_cluster_version"
            update_policy = "ALWAYS_UPDATE"
        }
    
        ###################
        # KUBERNETES NODPOOL
        # More info : https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_nodepool
        ###################
        nodepool = {
            name = "frontend-nextjs-nodepool"
            flavor_name = "your_nodepool_flavor"
            desired_nodes = "1"
            anti_affinity = true
        }
    }
}

variable "kubernetes_start_script" {
    type = string
    description = "The script for start the kubernetes cluster"
    default = "./kubernetes_start.sh"
}



#################################
# OVH S3 OBJECT STORAGE VARIABLES
#################################

variable "s3_storage" {
    type = map(string)
    description = "The s3 storage for the frontend"
    default = {
        name = "supabase-storage-s3"
        region = "your_storage_region"
    }
}

#################################
# OVH VM INSTANCE VARIABLES
#################################

variable "supabase_self_host" {
    type = map(any)
    description = "The supabase self host"
    default = {
        name = "supabase_host"
        region = "your_vm_region"
        billing_period = "hourly"

        # IMPORTANT !
        # FOR GET THE GOOD FLAVOR ID FOR YOUR MACHINE, NEED TO MAKE A REQUEST TO THE FOLOWING API 
        # https://api.ovh.com/1.0/cloud/project/{{SERVICE_NAME}}/flavor
        # NEED ACCESS_TOKEN IN THE HEADER REQUEST
        flavor_id = "your_vm_flavor_id" # d2-8 VM - GRA11

        # IMPORTANT !
        # FOR GET THE GOOD IMAGE ID FOR YOUR MACHINE, NEED TO MAKE A REQUEST TO THE FOLOWING API 
        # https://api.ovh.com/1.0/cloud/project/{{SERVICE_NAME}}/image
        # NEED ACCESS_TOKEN IN THE HEADER REQUEST
        image_id = "your_vm_image_id" # ubuntu 24.10 - GRA11

        network_public = true

        # OVH requires an SSH key value, but it won't be used since their API doesn't work properly
        # The actual SSH setup is handled through user_data script instead
        # This value can be ignored - it's just here to satisfy the API requirement
        ssh_key = "your_ssh_key_name"
        ssh_key_public = "your_ssh_public_key"

        # This user_data executes a script when the VM starts
        # WARNING: Do not modify ssh.bash as it fixes SSH connectivity issues with OVH's API
        # All custom scripts should be managed through Ansible instead
        user_data = "/path/to/your/ssh.bash"
    }
}


variable "env_vars" {
  type        = map(string)
  description = "Environment variables"
  default = {
    POSTGRES_PASSWORD  = "postgres_password"
    JWT_SECRET         = "jwt_secret_token_with_minimum_32_characters"
    ANON_KEY           = "anon_key_value"
    SERVICE_ROLE_KEY   = "service_role_key_value"
    DASHBOARD_USERNAME = "supabase"
    DASHBOARD_PASSWORD = "dashboard_password"
    SECRET_KEY_BASE    = "secret_key_base_value"
    VAULT_ENC_KEY      = "vault_encryption_key_32_chars_min"

    FILE_SIZE_LIMIT       = "1200428800"
    GLOBAL_S3_BUCKET      = "your_global_s3_bucket"
    GLOBAL_S3_ENDPOINT    = "https://your_s3_endpoint"
    AWS_DEFAULT_REGION    = "your_aws_region"
    TENANT_ID             = "your_tenant_id"
    REGION                = "your_region"
  }
}

# TODO : Need DOCKERHUB LOGIN (not another registry)
variable "docker_login" {
    type = map(string)
    description = "The docker login"
    default = {
        username = "docker_username"
        password = "docker_password"
    }
}