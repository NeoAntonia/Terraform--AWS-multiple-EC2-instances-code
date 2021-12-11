variable "key_path" {
  default = "~/.ssh/id_rsa.pub"

}

variable "server_names" {
  description = "Name of the Server"
  type    = list(string)
  default = ["Node1", "Node2", "Node3"] 
}

variable "instance-name" {
    default= "Some name"
}

variable "instance_types" {
  type = list(string)
  default = [ "t3.xlarge","t3.medium","t3.medium"]
}