variable "azure_resource_group" {
  type        = string
  description = "Name of the resource group in which to create the resources"
}

variable "azure_region" {
  type        = string
  description = "Azure region to create the resources in"
}

variable "env" {
  type        = string
  description = "Environment tag"
}
