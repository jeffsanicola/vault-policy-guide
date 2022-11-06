variable "users" {
  type        = list(string)
  description = "List of users to create"
  default = [
    "1", "2a", "2b", "3", "4a", "4b", "4c",
    "5a", "5b", "5c", "5d", "6a", "6b", "6c", "6d",
    "7", "8a", "8b", "9a", "9b", "10"
  ]
}

variable "default_password" {
  type        = string
  description = "Default password for example users"
  default     = "changeme"
}
