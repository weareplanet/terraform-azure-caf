resource "azurecaf_name" "custom_role" {
  name          = var.custom_role.name
  resource_type = "azurerm_role_definition"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_cosmosdb_sql_role_definition" "custom_role" {
  resource_group_name = var.custom_role.resource_group_name
  account_name        = var.custom_role.account_name
  assignable_scopes   = var.assignable_scopes
  name                = azurecaf_name.custom_role.result
  role_definition_id  = try(var.custom_role.role_definition_id, null)
  type                = try(var.custom_role.type, "CustomRole")

  permissions {
    data_actions = var.custom_role.permissions.data_actions
  }
}
