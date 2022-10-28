module "cosmosdb_custom_roles" {
  source   = "./modules/roles/cosmosdb_custom_roles"
  for_each = var.cosmosdb_role_definitions

  global_settings      = local.global_settings
  custom_role          = each.value
  assignable_scopes    = local.cosmos_db_assignable_scopes[each.key]
}

locals {
  cosmos_db_assignable_scopes = {
    for k, v in try(var.cosmosdb_role_definitions, {}) : k => flatten([
      for assignment_type, attrs in try(v.assignable_scopes, {}) : [
        for attr in attrs : [
          try(attr.id, local.cosmos_db_services_roles[assignment_type][try(attr.lz_key, var.current_landingzone_key)][attr.key].id)
        ]
      ]
    ])
  }

  cosmos_db_services_roles = {
    cosmos_dbs             = local.combined_objects_cosmos_dbs
    cosmosdb_sql_databases = local.combined_objects_cosmosdb_sql_databases
  }
}
