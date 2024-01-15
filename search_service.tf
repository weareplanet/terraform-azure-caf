module "search_services" {
  source   = "./modules/ai/search_services"
  for_each = local.search_services.search_services

  client_config       = local.client_config
  global_settings     = local.global_settings
  resource_group_name = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].name
  location            = lookup(each.value, "region", null) == null ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location : local.global_settings.regions[each.value.region]
  settings            = each.value
}

output "search_services" {
  value = module.search_services
}