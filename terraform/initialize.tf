variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "project_name" {
  description = "The name of the Google Cloud project"
  default = "gcloud-vpn-000"
}

variable "project_id" {
  description = "The ID of the Google Cloud project"
  default = "gcloud-vpn-000-998399"
}

variable "project_org" {
  description = "The ID of the Google Cloud project"
  default = "632143895003"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/gcloud_id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default     = "~/.ssh/gcloud_id_rsa"
}

variable "install_script_src_path" {
  description = "Path to install script within this repository"
  default     = "scripts/install.sh"
}

variable "install_script_dest_path" {
  description = "Path to put the install script on each destination resource"
  default     = "/tmp/install.sh"
}