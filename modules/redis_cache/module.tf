
resource "azurecaf_name" "redis" {

  name          = var.redis.name
  resource_type = "azurerm_redis_cache"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis" {
  name                = azurecaf_name.redis.result
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.redis.capacity
  family              = var.redis.family
  sku_name            = var.redis.sku_name
  tags                = local.tags

  enable_non_ssl_port           = lookup(var.redis, "enable_non_ssl_port", null)
  minimum_tls_version           = lookup(var.redis, "minimum_tls_version", "1.2")
  private_static_ip_address     = lookup(var.redis, "private_static_ip_address", null)
  public_network_access_enabled = lookup(var.redis, "public_network_access_enabled", null)
  shard_count                   = lookup(var.redis, "shard_count", null)
  zones                         = lookup(var.redis, "zones", null)
  redis_version                 = lookup(var.redis, "redis_version", null)
  subnet_id                     = try(var.subnet_id, null)

  dynamic "redis_configuration" {
    for_each = lookup(var.redis, "redis_configuration", {}) != {} ? [var.redis.redis_configuration] : []

    content {
      active_directory_authentication_enabled = lookup(redis_configuration.value, "active_directory_authentication_enabled", null)
      enable_authentication                   = lookup(redis_configuration.value, "enable_authentication", null)
      maxmemory_reserved                      = lookup(redis_configuration.value, "maxmemory_reserved", null)
      maxmemory_delta                         = lookup(redis_configuration.value, "maxmemory_delta", null)
      maxmemory_policy                        = lookup(redis_configuration.value, "maxmemory_policy", null)
      maxfragmentationmemory_reserved         = lookup(redis_configuration.value, "maxfragmentationmemory_reserved", null)
      rdb_backup_enabled                      = lookup(redis_configuration.value, "rdb_backup_enabled", null)
      rdb_backup_frequency                    = lookup(redis_configuration.value, "rdb_backup_frequency", null)
      rdb_backup_max_snapshot_count           = lookup(redis_configuration.value, "rdb_backup_max_snapshot_count", null)
      rdb_storage_connection_string           = lookup(redis_configuration.value, "rdb_storage_connection_string", null)
      notify_keyspace_events                  = lookup(redis_configuration.value, "notify_keyspace_events", null)
    }
  }

  dynamic "patch_schedule" {
    for_each = lookup(var.redis, "patch_schedule", {}) != {} ? [var.redis.patch_schedule] : []

    content {
      day_of_week    = patch_schedule.value.day_of_week
      start_hour_utc = lookup(patch_schedule.value, "start_hour_utc", null)
    }
  }
}

# Optional Access Policy Assignments for Redis Cache
resource "azurerm_redis_cache_access_policy_assignment" "this" {
  for_each = var.access_policy_assignments

  name               = each.key
  redis_cache_id     = azurerm_redis_cache.redis.id
  access_policy_name = each.value.access_policy_name

  # Resolve object_id from managed_identity_key (optionally across LZ) with guards; fallback to explicit object_id.
  object_id = (
    (
      can(var.managed_identities[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.managed_identity_key].principal_id)
    ) ? var.managed_identities[try(each.value.lz_key, var.client_config.landingzone_key)][each.value.managed_identity_key].principal_id : (
      can(var.managed_identities[var.client_config.landingzone_key][each.value.managed_identity_key].principal_id)
      ? var.managed_identities[var.client_config.landingzone_key][each.value.managed_identity_key].principal_id
      : each.value.object_id
    )
  )

  object_id_alias = try(each.value.object_id_alias, null)

  # Optional: uncomment to enforce a clear error when object_id cannot be resolved
  # lifecycle {
  #   precondition {
  #     condition     = try(length(object_id) > 0, false)
  #     error_message = "Redis access policy assignment needs a valid object_id (MSI not found and no explicit object_id provided)."
  #   }
  # }
}

