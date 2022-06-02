global_settings = {
  default_region = "region1"
  regions = {
    region1 = "northeurope"
  }
}

resource_groups = {
  test = {
    name = "test"
  }
}

vnets = {
  vnet1 = {
    resource_group_key = "test"
    vnet = {
      name          = "test-vn"
      address_space = ["10.2.0.0/16"]
    }
    specialsubnets = {
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" # must be named AzureFirewallSubnet
        cidr = ["10.2.1.0/24"]
      }
    }
    subnets = {}
  }
}

public_ip_addresses = {
  pip1 = {
    name               = "pip1-name"
    resource_group_key = "test"
    sku                = "Standard" # must be 'Standard' SKU
    # Standard SKU Public IP Addresses that do not specify a zone are zone redundant by default.
    allocation_method       = "Static"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }
}

azurerm_firewalls = {
  firewall1 = {
    name                = "test-firewall"
    resource_group_key  = "test"
    vnet_key            = "vnet1"
    sku_tier            = "Premium"
    zones               = [1, 2, 3]
    firewall_policy_key = "policy1"
    public_ips = {
      ip1 = {
        name          = "pip1"
        public_ip_key = "pip1"
        vnet_key      = "vnet1"
        subnet_key    = "AzureFirewallSubnet"
        # lz_key = "lz_key"
      }
      # ip2 = {
      #   name = "pip2"
      #   public_ip_id = "azure_resource_id"
      #   subnet_id = "azure_resource_id"
      # }
    }
  }
}

azurerm_firewall_policies = {
  policy1 = {
    name               = "firewall_policy"
    resource_group_key = "test"
    region             = "region1"
    sku                = "Premium"

    #   threat_intelligence_mode = "Alert"

    #   threat_intelligence_allowlist = {
    #     ip_addresses = []
    #     fqdns        = []
    #   }

    #   intrusion_detection = {
    #     mode                = "Alert"
    #     signature_overrides = {
    #       id    = ""
    #       state = ""
    #     }
    #     traffic_bypass      = {
    #       name                  = ""
    #       protocol              = ""
    #       description           = ""
    #       destination_addresses = ""
    #       destination_ip_groups = ""
    #       destination_ports     = ""
    #       source_addresses      = ""
    #       source_ip_groups      = ""
    #     }
  }
}

azurerm_firewall_policy_rule_collection_groups = {
  group1 = {
    #firewall_policy_id = "Azure Resource ID"
    firewall_policy_key = "policy1"
    name                = "example-fwpolicy-rcg"
    priority            = 500

    application_rule_collections = {
      rule1 = {
        name     = "app_rule_collection1"
        priority = 500
        action   = "Deny"
        rules = {
          rule1 = {
            name = "app_rule_collection1_rule1"
            protocols = {
              1 = {
                type = "Http"
                port = 80
              }
              2 = {
                type = "Https"
                port = 443
              }
            }
            source_addresses  = ["10.0.0.1"]
            destination_fqdns = ["*.microsoft.com"]
          }
        }
      }
    }

    network_rule_collections = {
      group1 = {
        name     = "network_rule_collection1"
        priority = 400
        action   = "Deny"
        rules = {
          rule1 = {
            name                  = "network_rule_collection1_rule1"
            protocols             = ["TCP", "UDP"]
            source_addresses      = ["10.0.0.1"]
            destination_addresses = ["192.168.1.1", "192.168.1.2"]
            destination_ports     = ["80", "1000-2000"]
          }
        }
      }
    }

    nat_rule_collections = {
      group1 = {
        name     = "nat_rule_collection1"
        priority = 300
        action   = "Dnat"
        rules = {
          rule1 = {
            name             = "nat_rule_collection1_rule1"
            protocols        = ["TCP"]
            source_addresses = ["*"]
            # destination_address = "192.168.1.1"
            destination_address_public_ip_key = "pip1"
            destination_ports                 = ["80"]
            translated_address                = "192.168.0.1"
            translated_port                   = "8080"
          }
        }
      }
    }
  }

}
