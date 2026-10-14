data "aws_instance" "existing" {
  instance_id = "i-02939095a3823ce40"
}

data "aws_vpc" "existing" {
  id = "vpc-079fd9061654ab6f0"
}

output "existing_instance_state" {
  value = data.aws_instance.existing.instance_state
}

output "existing_instance_type" {
  value = data.aws_instance.existing.instance_type
}

output "existing_instance_public_ip" {
  value = data.aws_instance.existing.public_ip
}

output "existing_vpc_id" {
  value = data.aws_vpc.existing.id
}
