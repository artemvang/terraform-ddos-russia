variable "instances_count" {
  type    = number
}

variable "private_key_pem" {
  type = string
}

variable "server_image" {
  type        = string
  description = "The server image"
  default     = "ubuntu-20.04"
}

variable "location" {
  type        = string
  description = "Server location"
  default     = "hel1"
}

variable "server_type" {
  type        = string
  description = "Server type"
  default     = "cx11"
}

variable "ip_addr" {
  type        = string
  description = "Target's ip address"
}

variable "ip_port" {
  type        = string
  description = "Target's ip port"
}

variable "httpflood" {
  type        = bool
  description = "Do http floodaewaeawewaeawe"
  default     = false
}

variable "dnsflood" {
  type        = bool
  description = "Do dns flood"
  default     = false
}

variable "synflood" {
  type        = bool
  description = "Do syn flood"
  default     = false
}

variable "icmpflood" {
  type        = bool
  description = "Do icmp flood"
  default     = false
}

variable "db1000n" {
  type        = bool
  description = "Do db1000n flood"
  default     = false
}
