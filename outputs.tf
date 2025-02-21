#################################
# GLOBAL OUTPUTS
#################################













#################################
# KUBERNETES CLUSTER  OUTPUTS
#################################








#################################
# OVH S3 OBJECT STORAGE OUTPUTS
#################################











#################################
# OVH VM INSTANCE OUTPUTS
#################################

output "supabase_dashboard_url" {
  value = "URL for the dashboard supabase : http://${local.ipv4_address}:8000"
}




