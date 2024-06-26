# Define Azure Resource Group
resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.location
}
# Define Azure Role Assignment
#resource "azurerm_role_assignment" "role_acrpull" {
#  scope                = azurerm_container_registry.acr.id
#  role_definition_name = "AcrPull"
 # principal_id         = azurerm_linux_web_app.my-web-app.identity.0.principal_id
 # skip_service_principal_aad_check = true
# }

# Define Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.docker_registry_name
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = azurerm_resource_group.aks-rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Define Azure Service Plan
resource "azurerm_service_plan" "my-service-plan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = azurerm_resource_group.aks-rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Define Azure Linux Web App
resource "azurerm_linux_web_app" "my-web-app" {
  name                = var.web-app-name
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = azurerm_resource_group.aks-rg.location
  service_plan_id     = azurerm_service_plan.my-service-plan.id

  site_config {
    always_on = true

    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/react-app"
      docker_image_tag = "latest"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = azurerm_container_registry.acr.login_server
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
    WEBSITES_PORT                   = var.websites_port
  }
}


