region = "us-west-1"

availability_zones = ["us-west-1b", "us-west-1c"]

namespace = "eg"

stage = "test"

name = "ec2-bastion"

ami = "ami-0f56279347d2fa43e"

instance_type = "t3a.nano"

ssh_user = "ubuntu"

ssh_key_path = "./secrets"

generate_ssh_key = true

user_data = [
  "apt-get install -y postgresql-client-common"
]

security_groups = []

ingress_security_groups = []