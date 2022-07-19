
resource "null_resource" "set_probe" {

  for_each = try(var.settings.probes, {})

  triggers = {
    probe = jsonencode(each.value)
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/set_resource.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = fail

    environment = {
      RESOURCE                     = "PROBE"
      RG_NAME                      = var.application_gateway.resource_group_name
      APPLICATION_GATEWAY_NAME     = var.application_gateway.name
      APPLICATION_GATEWAY_ID       = var.application_gateway.id
      NAME                         = each.value.name
      PROTOCOL                     = each.value.protocol
      PROBEPATH                    = each.value.path
      HOST                         = try(each.value.host, null)
      HOST_NAME_FROM_HTTP_SETTINGS = try(each.value.host_name_from_http_settings, null)
      INTERVAL                     = try(each.value.interval, null)
      MATCH_BODY                   = try(each.value.match_body, null)
      MATCH_STATUS_CODES           = try(each.value.match_status_codes, null)
      MIN_SERVERS                  = try(each.value.min_servers, null)
      PORT                         = try(each.value.port, null)
      THRESHOLD                    = try(each.value.threshold, null)
      TIMEOUT                      = try(each.value.timeout, null)
    }
  }
}

resource "null_resource" "delete_probe" {

  for_each = try(var.settings.probes, {})

  triggers = {
    probe_name               = each.value.name
    resource_group_name      = var.application_gateway.resource_group_name
    application_gateway_name = var.application_gateway.name
    application_gateway_id   = var.application_gateway.id
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/delete_resource.sh", path.module)
    when        = destroy
    interpreter = ["/bin/bash"]
    on_failure  = fail

    environment = {
      RESOURCE                 = "PROBE"
      NAME                     = self.triggers.probe_name
      RG_NAME                  = self.triggers.resource_group_name
      APPLICATION_GATEWAY_NAME = self.triggers.application_gateway_name
      APPLICATION_GATEWAY_ID   = self.triggers.application_gateway_id
    }
  }
}