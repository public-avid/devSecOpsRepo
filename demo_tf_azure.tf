provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.21.0"
}

resource "azurerm_security_center_contact" "example" {
  email = "contact@example.com"
  phone = "+1-555-555-5555"

  alert_notifications = false
  alerts_to_admins    = false
}

resource "azurerm_security_center_subscription_pricing" "example" {
  tier = "Standard"
}

resource "azurerm_virtual_machine" "main_linux" {

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine" "main_windows" {

  os_profile_linux_config {
    enable_automatic_upgrades = false
  }
}

resource "azurerm_storage_account" "testsa" {
  name                     = "storageaccountname"
  resource_group_name      = "${azurerm_resource_group.testrg.name}"
  location                 = "westus"
  account_tier             = "Standard"
  enable_blob_encryption   = false
  enable_file_encryption   = false

  tags {
    environment = "staging"
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acceptanceTestResourceGroup1"
  location = "West US"
}

resource "azurerm_sql_server" "test" {
  name                         = "mysqlserver"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_database" "test" {
  name                = "mysqldatabase"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "West US"
  server_name         = "${azurerm_sql_server.test.name}"

  threat_detection_policy {
    state                 = "Disabled"
    disabled_alerts       = "Sql_Injection_Vulnerability"
    email_account_admins  = false
    email_addresses       = ["a@sophos.com","b@sophos.com"]
    retention_days        = 70
  }
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestmd"
  location             = "West US 2"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  encryption_settings {
    enabled = false
  }
}

resource "azurerm_monitor_log_profile" "test" {
  name = "default"

  categories = [
    "Action",
    "Delete",
    "Write",
  ]

  locations = [
    "westus",
    "global",
  ]

  # RootManageSharedAccessKey is created by default with listen, send, manage permissions
  servicebus_rule_id = "${azurerm_eventhub_namespace.test.id}/authorizationrules/RootManageSharedAccessKey"
  storage_account_id = "${azurerm_storage_account.test.id}"

  retention_policy {
    enabled = true
    days    = 7
  }
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Production"
  }
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "FirewallRule1"
  resource_group_name = "usygd"
  server_name         = "sjhgd"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "10.0.17.62"
}