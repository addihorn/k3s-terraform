## defines variables used by the cluster setup

variable "k3s_agent_token" {
  type = string
  default = "superSecretToken"
}

variable "k3s_version" {
  type = string
  default = "v1.20.7+k3s1"
}


