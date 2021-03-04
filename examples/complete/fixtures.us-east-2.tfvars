region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "ec2-bastion"

instance_type = "t3a.nano"

ssh_key_path = "./secrets"

generate_ssh_key = true

user_data = [
  "yum install -y postgresql-client-common"
]

security_groups = []

root_block_device_encrypted = true

metadata_http_tokens_required = true

associate_public_ip_address = true