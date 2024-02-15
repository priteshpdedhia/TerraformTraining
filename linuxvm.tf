resource "azurerm_resource_group" "linuxvm" {
  name     = "LinuxVM"
  location = "Eastus"
}

resource "azurerm_virtual_network" "linuxvm" {
  name                = "linuxvm-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.linuxvm.location
  resource_group_name = azurerm_resource_group.linuxvm.name
}

resource "azurerm_subnet" "linuxvm" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.linuxvm.name
  virtual_network_name = azurerm_virtual_network.linuxvm.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "linuxvm" {
  name                = "linuxvm-nic"
  location            = azurerm_resource_group.linuxvm.location
  resource_group_name = azurerm_resource_group.linuxvm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.linuxvm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.iptest.id
  }
}

resource "azurerm_public_ip" "linuxiptest" {
  name = "ip-vm"
  resource_group_name = azurerm_resource_group.linuxvm.name
  location = azurerm_resource_group.linuxvm.location
  allocation_method = "Static" 
}


resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "Kyndryl-LinuxVM"
  resource_group_name = azurerm_resource_group.linuxvm.name
  location            = azurerm_resource_group.linuxvm.location
  size                = "Standard_F2"
  admin_username      = "terraform"
  admin_password      = "1qaz@wsx#edc"
disable_password_authentication = false 
  network_interface_ids = [
    azurerm_network_interface.linuxvm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
      publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}