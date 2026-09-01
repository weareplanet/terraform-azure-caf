# Server auditing

data "azurerm_storage_account" "mssql_auditing" {
  count = try(var.settings.extended_auditing_policy.storage_account.key, null) == null ? 0 : 1

  name                = var.storage_accounts[var.settings.extended_auditing_policy.storage_account.key].name
  resource_group_name = var.storage_accounts[var.settings.extended_auditing_policy.storage_account.key].resource_group_name
}

resource "azurerm_mssql_server_extended_auditing_policy" "mssql" {
  count = try(var.settings.extended_auditing_policy, null) == null ? 0 : 1

  server_id                               = azurerm_mssql_server.mssql.id
  storage_endpoint                        = try(data.azurerm_storage_account.mssql_auditing.0.primary_blob_endpoint, null)
  storage_account_access_key              = try(data.azurerm_storage_account.mssql_auditing.0.primary_access_key, null)
  storage_account_access_key_is_secondary = false
  retention_in_days                       = try(var.settings.extended_auditing_policy.retention_in_days, 0)
  log_monitoring_enabled                  = try(var.settings.extended_auditing_policy.log_monitoring_enabled, true)
}