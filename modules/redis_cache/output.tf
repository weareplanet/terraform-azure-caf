
output "redis_cache" {
  value = azurerm_redis_cache.redis
}

output "access_policy_assignments" {
  description = "Map of access policy assignments created for the Redis cache."
  value       = azurerm_redis_cache_access_policy_assignment.this
}