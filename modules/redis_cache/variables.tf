variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "tags" {
  description = "(Required) Map of tags to be applied to the resource"
  type        = map(any)
}

variable "redis" {}

variable "subnet_id" {
  description = "The ID of the Subnet within which the Redis Cache should be deployed"
  type        = string
  default     = null
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

variable "diagnostic_profiles" {
  default = {}
}
variable "diagnostics" {
  default = null
}
variable "vnets" {
  default = {}
}
variable "private_endpoints" {
  default = {}
}
variable "private_dns" {
  default = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "access_policy_assignments" {
  description = "Map of access policy assignments to grant on the Redis cache. Key is the assignment name. Each value should include access_policy_name, object_id, and optional object_id_alias."
  default     = {}
}

variable "managed_identities" {
  description = "Combined objects map of managed identities to resolve principal IDs when a managed_identity_key is provided in access_policy_assignments."
  default     = {}
}
