locals {
  network_configuration_keys = flatten(concat([
    for vm_name, vm_config in var.azure_linux_vms : [
      for nic in vm_config.network_configuration.nics :
      "${vm_name}:${nic.name}"
    ]
  ]))
  network_configuration_values = flatten(concat([
    for vm_name, vm_config in var.azure_linux_vms : [
      for nic in vm_config.network_configuration.nics :
      {
        vm                = vm_name
        name              = nic.name
        ip_configurations = nic.ip_configurations
      }
    ]
  ]))
  network_configuration_data = zipmap(local.network_configuration_keys, local.network_configuration_values)
}