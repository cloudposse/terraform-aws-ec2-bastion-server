#!/usr/bin/bash -e
#
# Bastion Bootstrapping

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
date '+%Y-%m-%d %H:%M:%S'

# Configuration
PROGRAM='Linux Bastion'
IMDS_BASE_URL='http://169.254.169.254/latest'

##################################### Functions Definitions
function imdsv2_token() {
    curl -X PUT "$${IMDS_BASE_URL}/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600"
}

function imds_request() {
    REQUEST_PATH=$1
    if [ -z $TOKEN ]
    then
        TOKEN=$(imdsv2_token)
    fi
    curl -sH "X-aws-ec2-metadata-token: $${TOKEN}" "$${IMDS_BASE_URL}/$${REQUEST_PATH}"
}

function setup_environment_variables() {
    REGION=$(imds_request meta-data/placement/availability-zone/)
    # Example: us-east-1a => us-east-1
    REGION=$${REGION: :-1}
    _userdata_file="/var/lib/cloud/instance/user-data.txt"
    INSTANCE_ID=$(imds_request meta-data/instance-id)
    CWG=$(grep CLOUDWATCHGROUP $${_userdata_file} | sed 's/CLOUDWATCHGROUP=//g')
    export REGION CWG INSTANCE_ID
}

function verify_dependencies(){
    echo "$${FUNCNAME[0]} Started"
    if [ "a$(which aws)" = "a" ]
    then
      pip install awscli
    fi
    echo "$${FUNCNAME[0]} Ended"
}

function osrelease () {
    OS=`cat /etc/os-release | grep '^NAME=' |  tr -d \" | sed 's/\n//g' | sed 's/NAME=//g'`
    if [ "$${OS}" = "Amazon Linux AMI" ] || [ "$${OS}" = "Amazon Linux" ]
    then
        echo "AMZN"
    else
        echo "Operating System Not Found"
    fi
}

function setup_ssh() {
    echo "$${FUNCNAME[0]} Started"

    cat <<EOF > /home/${ssh_user}/.ssh/config
Host *
    StrictHostKeyChecking no
EOF
    if [ "${tcp_forwarding}" = "false" ]
    then
        awk '!/AllowTcpForwarding/' /etc/ssh/sshd_config > temp && mv temp /etc/ssh/sshd_config
        echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
    fi
    if [ "${x11_forwarding}" = "false" ]
    then
        awk '!/X11Forwarding/' /etc/ssh/sshd_config > temp && mv temp /etc/ssh/sshd_config
        echo "X11Forwarding no" >> /etc/ssh/sshd_config
    fi

    chmod 600 /home/${ssh_user}/.ssh/config
    chown ${ssh_user}:${ssh_user} /home/${ssh_user}/.ssh/config

    echo "$${FUNCNAME[0]} Ended"
}

function setup_ssm() {
    echo "$${FUNCNAME[0]} Started"

    if [ "${ssm_enabled}" = "true" ]
    then
        systemctl enable amazon-ssm-agent
        systemctl start amazon-ssm-agent
        systemctl status amazon-ssm-agent
    else
        systemctl disable amazon-ssm-agent
        systemctl stop amazon-ssm-agent
        systemctl status amazon-ssm-agent
    fi

    echo "$${FUNCNAME[0]} Ended"
}

function setup_logs () {
    echo "$${FUNCNAME[0]} Started"

    if [ "$${release}" = "AMZN" ]
    then
        curl "https://amazoncloudwatch-agent-$${REGION}.s3.$${REGION}.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm" -O
        rpm -U ./amazon-cloudwatch-agent.rpm
        rm ./amazon-cloudwatch-agent.rpm
    fi

    cat <<EOF >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "logs": {
        "force_flush_interval": 5,
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/audit/audit.log",
                        "log_group_name": "${cloudwatch_group}",
                        "log_stream_name": "$${INSTANCE_ID}",
                        "timestamp_format": "%Y-%m-%d %H:%M:%S",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    }
}
EOF

    systemctl enable amazon-cloudwatch-agent.service
    systemctl restart amazon-cloudwatch-agent.service

    echo "$${FUNCNAME[0]} Ended"
}

function setup_os () {
    echo "$${FUNCNAME[0]} Started"

    echo "Defaults env_keep += \"SSH_CLIENT\"" >> /etc/sudoers

    if [ "$${release}" = "AMZN" ]
    then
        user_group="ec2-user"
        echo "0 0 * * * yum -y update --security" > ~/mycron
    fi

    crontab ~/mycron
    rm ~/mycron

    echo "$${FUNCNAME[0]} Ended"
}

function setup_banner() {
    echo "$${FUNCNAME[0]} Started"

    BANNER_FILE="/etc/ssh/sshd_banner"
    echo "Creating Banner in $${BANNER_FILE}"
    cat <<EOF >> "$${BANNER_FILE}"
###############################################################################
#                          _                                                  #
#                         | |                                                 #
#                         | |_    ___   _ __ ___                              #
#                         | __|  / _ \ | `_ ` _ \                             #
#                         | |_  |  __/ | | | | | |                            #
#                          \__|  \___| |_| |_| |_| (_)                        #
# --------------------------------------------------------------------------- #
#                         Welcome to tem. SSH Bastion                         #
#                All actions will be monitored and recorded.                  #
###############################################################################
EOF
    if [ -e $${BANNER_FILE} ]
    then
        echo "[INFO] Installing banner ... "
        echo -e "\n Banner $${BANNER_FILE}" >> /etc/ssh/sshd_config
    else
        echo "[INFO] banner file is not accessible skipping ..."
        exit 1;
    fi

    echo "$${FUNCNAME[0]} Ended"
}

function prevent_process_snooping() {
    # Prevent bastion host users from viewing processes owned by other users.
    mount -o remount,rw,hidepid=2 /proc
    awk '!/proc/' /etc/fstab > temp && mv temp /etc/fstab
    echo "proc /proc proc defaults,hidepid=2 0 0" >> /etc/fstab
    echo "$${FUNCNAME[0]} Ended"
}

##################################### End Function Definitions

release=$(osrelease)
if [ "$${release}" = "Operating System Not Found" ]
then
    echo "[ERROR] Unsupported Linux Bastion OS"
    exit 1
fi

verify_dependencies
setup_environment_variables
setup_banner
setup_ssh
setup_os
setup_logs
setup_ssm
prevent_process_snooping

echo "Bootstrap complete."
