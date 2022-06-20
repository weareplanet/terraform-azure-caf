module "compute_instance" {
  source     = "./settings"
  depends_on = [azurerm_app_configuration.config]

  resource_group_name = var.resource_group_name
  key_names           = keys(local.config_settings)
  key_values          = values(local.config_settings)
  config_name         = azurecaf_name.app_config.result
  tags                = local.tags
  global_settings     = var.global_settings
}

resource "azurerm_app_configuration_key" "kv" {
  for_each = try(local.config_settings, {})

  configuration_store_id = azurerm_app_configuration.config.id
  key                    = each.key
  label                  = try(each.value.label, null)
  value                  = each.value.value
  tags                   = local.tags
}
