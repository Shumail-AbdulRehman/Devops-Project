# Private DNS Zone for MySQL
resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.project_name}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.project_name}-mysql-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.project_name}-${var.environment}-mysql"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  administrator_login    = var.db_username
  administrator_password = var.db_password
  
  sku_name   = var.db_sku_name
  version    = "8.0.21"
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  
  delegated_subnet_id = azurerm_subnet.database.id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id
  
  storage {
    size_gb = var.db_storage_gb
    iops    = 360
  }
  
  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
  
  tags = {
    Name = "${var.project_name}-mysql"
  }
}

# MySQL Database
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# MySQL Firewall Rule (Allow Azure Services)
resource "azurerm_mysql_flexible_server_firewall_rule" "azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
