output "nic_ids" {
  value = [
    for nic in local.network_configuration_data : azurerm_network_interface.azure_linux_vm_nics["${nic.vm}:${nic.name}"].id
  ]
}