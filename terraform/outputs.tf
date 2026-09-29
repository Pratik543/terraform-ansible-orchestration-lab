output "ubuntu_ansible_master_instance" {
  description = "ID and public IP of the Ubuntu Ansible master"
  value = {
    id        = aws_instance.ubuntu_ansible_master.id
    public_ip = aws_instance.ubuntu_ansible_master.public_ip
  }
}

output "ubuntu_ansible_master_ssh_command" {
  description = "SSH command for the Ubuntu Ansible master"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.ubuntu_ansible_master.public_ip}"
}

output "ubuntu_ansible_workers" {
  description = "Connection details for the numbered Ubuntu Ansible workers"
  value = {
    for instance in aws_instance.ubuntu_ansible_worker :
    instance.tags["Name"] => {
      id          = instance.id
      name        = instance.tags["Name"]
      environment = instance.tags["Environment"]
      public_ip   = instance.public_ip
      ssh         = "ssh -i ${var.key_name}.pem ubuntu@${instance.public_ip}"
    }
  }
}
