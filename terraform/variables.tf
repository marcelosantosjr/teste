variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefixo para nomear recursos"
  type        = string
  default     = "devops"
}

variable "vm_size" {
  description = "SKU da VM"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Usuário administrador da VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "Chave pública SSH para acesso à VM"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorizado para SSH"
  type        = string
  default     = "0.0.0.0/0"
}
