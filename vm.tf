provider "azurerm" {
}

resource "azurerm_resource_group" "myterraformgroup" {
  name      = "myResourceGroup"
  location  = "southeastasia"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_network" "myterraformnetwork" {
  name                  = "myVnet"
  address_space         = ["10.0.0.0/16"]
  location              = "southeastasia"
  resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_subnet" "myterraformsubnet" {
  name                  = "mySubnet"
  resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
  virtual_network_name  = "${azurerm_virtual_network.myterraformnetwork.name}"
  address_prefix        = "10.0.2.0/24"
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                 = "myPublicIP"
  location             = "southeastasia"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  allocation_method    = "Dynamic"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_security_group" "myterraformnsg" {
  name = "myNetworkSecurityGroup"
  location = "southeastasia"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"

  security_rule {
    name                        = "SSH"
    priority                    = "1001"
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_interface" "myterraformnic" {
  name                        = "myNIC"
  location                    = "southeastasia"
  resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_id   = "${azurerm_network_security_group.myterraformnsg.id}"

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }

  tags {
    environment = "Terraform Demo"
  }
}

# Use for creating storage account.
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined.
    resource_group = "${azurerm_resource_group.myterraformgroup.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                        = "diag${random_id.randomId.hex}"
  resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
  location                    = "southeastasia"
  account_replication_type    = "LRS"
  account_tier                = "Standard"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
  name = "myVM"
  location = "southeastasia"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
  network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size = "Standard_DS1_V2"

  storage_os_disk {
    name = "myOsDisk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
 
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "{id_rsa.pub}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "Terraform Demo"
  }
}
