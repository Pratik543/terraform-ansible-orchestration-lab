variable "ubuntu_ansible_master_ami_id" {
  type        = string
  description = "The AMI ID to use for the Ubuntu Ansible master instance"
}

variable "ubuntu_ansible_worker_ami_id" {
  type        = string
  description = "The AMI ID to use for the Ubuntu Ansible worker instances"
}

variable "ansible_worker_count" {
  type        = number
  default     = 1
  description = "The number of Ubuntu Ansible worker instances to create"

  validation {
    condition     = var.ansible_worker_count >= 1 && floor(var.ansible_worker_count) == var.ansible_worker_count
    error_message = "ansible_worker_count must be a positive whole number."
  }
}

variable "key_name" {
  type        = string
  description = "The EC2 key pair name to use for the instances"
}

variable "ubuntu_ansible_master_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The EC2 instance type to use for the Ubuntu Ansible master"
}

variable "ubuntu_ansible_worker_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The EC2 instance type to use for the Ubuntu Ansible workers"
}

variable "name_prefix" {
  type        = string
  default     = "ansible-orchestration-lab"
  description = "Prefix used for all resource Name tags"
}
