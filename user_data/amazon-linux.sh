#!/usr/bin/env bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

##
## Setup SSH Config
##
cat <<"__EOF__" > /home/${ssh_user}/.ssh/config
Host *
    StrictHostKeyChecking no
__EOF__
chmod 600 /home/${ssh_user}/.ssh/config
chown ${ssh_user}:${ssh_user} /home/${ssh_user}/.ssh/config

##
## Enable SSM
##
if [  "${ssm_enabled}" = "true" ]
then
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    systemctl status amazon-ssm-agent
else
    systemctl disable amazon-ssm-agent
    systemctl stop amazon-ssm-agent
    systemctl status amazon-ssm-agent
fi

if [  "${ec2_instance_connect_enabled}" = "true" ]
then
    sudo yum install ec2-instance-connect
    sudo less /etc/ssh/sshd_config
fi

${user_data}