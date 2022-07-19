resource "azurecaf_name" "topic_auth_rule" {
  name          = var.settings.name
  resource_type = "azurerm_servicebus_topic_authorization_rule"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}


resource "azurerm_servicebus_topic_authorization_rule" "topic_auth_rule" {
  name = azurecaf_name.topic_auth_rule.result
  # namespace_id      = var.remote_objects.servicebus_namespace_id
  topic_id = var.remote_objects.servicebus_topic_id
  # resource_group_name = var.remote_objects.resource_group_name
  listen = try(var.settings.listen, null)
  send   = try(var.settings.send, null)
  manage = try(var.settings.manage, null)
}