#!/usr/bin/env bash

##############
# Install deps
##############

apt-get update
apt-get -y install python-pip jq nfs-common pv mysql-client figlet make

# Generate system banner
figlet "${stage}" > /etc/motd

# Install AWS Client
pip install --upgrade awscli

# Setup DNS Search domains
echo 'search ${search_domains}' > '/etc/resolvconf/resolv.conf.d/base'
resolvconf -u

# Setup local vanity hostname
echo '${hostname}' | sed 's/\.$//' > /etc/hostname
hostname `cat /etc/hostname`

# Setup default `make` alias
echo 'alias make="make -C /usr/local/include --no-print-directory"' >> /etc/skel/.bash_aliases
cp /etc/skel/.bash_aliases /root/.bash_aliases
cp /etc/skel/.bash_aliases /home/${ssh_user}/.bash_aliases

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
## Setup Automatic Backups of Assets
##
cat <<"__EOF__" > /usr/local/bin/backup_assets.sh
#!/bin/bash
if [ "${assets_backup_enabled}" = "true" ]; then
  echo "Asset backup started"
  aws s3 sync --exact-timestamps --no-follow-symlinks /efs/ s3://${assets_bucket}/
  echo "Asset backup finished"
else
  echo "Asset backup disabled"
fi
__EOF__
chmod +x /usr/local/bin/backup_assets.sh

# Add to cron
if [ "${assets_backup_enabled}" == "true" ]; then
  croncmd="/usr/local/bin/backup_assets.sh"
  cronjob="${assets_backup_frequency} $croncmd"
  ( crontab -u ${ssh_user} -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -u ${ssh_user} -
fi

## 
## MySQL Client Configuration
## 
cat <<"__EOF__" > /root/.my.cnf
[client]
database=${db_name}
user=${db_user}
password=${db_password}
host=${db_host}
#host=${db_host_replicas}
__EOF__
chmod 600 /root/.my.cnf

echo 'default:: help' > /usr/local/include/Makefile
echo '-include Makefile.*' >> /usr/local/include/Makefile


##
## Makefile help
##
cat <<"__EOF__" > /usr/local/include/Makefile.help

# Ensures that a variable is defined
define assert-set
  @[ -n "$($1)" ] || (echo "$(1) not defined in $(@)"; exit 1)
endef

default:: help

.PHONY : help
## This help screen
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-\_0-9%:\\]+:/ { \
			helpMessage = match(lastLine, /^## (.*)/); \
			if (helpMessage) { \
					helpCommand = $$$1; \
					helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
						gsub("\\\\", "", helpCommand); \
						gsub(":+$$$", "", helpCommand); \
					printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
			} \
	} \
	{ lastLine = $$$0 }' $(MAKEFILE_LIST) | sort -u
	@printf "\n"

__EOF__
chmod 644 /usr/local/include/Makefile.help


##
## Makefile for cloud commands
##
cat <<"__EOF__" > /usr/local/include/Makefile.cloud
REGION ?= "${region}"
STAGE ?= "${stage}"
NAMESPACE ?= "${namespace}"
ASSETS_BUCKET ?= "${assets_bucket}"

.PHONY : list-instances
## List instances
list-instances:
	@aws ec2 describe-instances \
	--filters Name=tag:Stage,Values=$(STAGE) Name=tag:Namespace,Values=$(NAMESPACE) \
	--region $(REGION) | jq \
	".Reservations[].Instances[] |  \"Id: \(.InstanceId), Type: \(.InstanceType),  Name: \( .Tags[] | select( .Key == \"Name\" ) | .Value ), State: \(.State.Name), KeyPair: \(.KeyName), PrivateIp: \(.PrivateIpAddress), PublicIp: \(.PublicIpAddress)\""

.PHONY : list-instances-raw
## List instances in json format
list-instances-raw:
	@aws ec2 describe-instances \
	--filters Name=tag:Stage,Values=$(STAGE) Name=tag:Namespace,Values=$(NAMESPACE) \
	--region $(REGION)

## Backup assets to S3
backup-assets:
	@/usr/local/bin/backup_assets.sh

## Restore assets from S3
restore-assets:
	@aws s3 sync s3://$(ASSETS_BUCKET)/ /efs/ --exact-timestamps
	chmod -R 777 /efs

__EOF__
chmod 644 /usr/local/include/Makefile.cloud

##
## Makefile for varnish commands
##
cat <<"__EOF__" > /usr/local/include/Makefile.varnish
URL_PATH ?= /
APP ?= ${app}
REGION ?= "${region}"

.PNONY : purge-path
## Purge specific page by path
purge-path:
	@aws ssm send-command \
	--document-name $(APP)-purge-page \
	--max-errors 10 \
	--region $(REGION) \
	--targets "Key=tag:Name,Values=$(APP)" \
	--comment="Flushing varnish cache" \
	--parameters path=$(URL_PATH)

.PHONY : purge-all
## Purge all pages
purge-all:
	@aws ssm send-command  \
	--document-name $(APP)-purge-all \
	--max-errors 10 \
	--region $(REGION) \
	--targets "Key=tag:Name,Values=$(APP)" \
	--comment="Flushing varnish cache"

__EOF__
chmod 644 /usr/local/include/Makefile.varnish

##
## Makefile for MySQL commands
##

curl https://raw.githubusercontent.com/cloudposse/mysql_fix_encoding/2.0/fix_it.sh -o /usr/local/bin/mysql_latin_utf8.sh
chmod +x /usr/local/bin/mysql_latin_utf8.sh

curl https://github.com/cloudposse/rds-snapshot-restore/blob/1.0/rds_restore_cluster_from_snapshot.sh -o /usr/local/bin/rds_restore_cluster_from_snapshot.sh
chmod +x /usr/local/bin/rds_restore_cluster_from_snapshot.sh

cat <<"__EOF__" > /usr/local/include/Makefile.mysql
DUMP ?= /tmp/dump.sql

.PNONY : db-import
## Import dump to
db-import:
	@pv $(DUMP) | sudo mysql --defaults-file=/root/.my.cnf
	/usr/local/bin/mysql_latin_utf8.sh | pv | sudo mysql --defaults-file=/root/.my.cnf
__EOF__
chmod 644 /usr/local/include/Makefile.mysql

cat <<"__EOF__" > /usr/local/include/Makefile.rds
CLUSTER ?= ${db_cluster_name}

.PNONY : restore-from-snapshot
## Restore dump from snapshot. Specify SNAPSHOT_ID and DRY_RUN=false
restore-from-snapshot:
	$(call assert-set,SNAPSHOT_ID)
	$(call assert-set,DRY_RUN)
	@DRY_RUN=$(DRY_RUN) MASTER_PASSWORD=$(shell sudo cat /root/.my.cnf | grep password | cut -d'=' -f2) /usr/local/bin/rds_restore_cluster_from_snapshot.sh $(CLUSTER) $(SNAPSHOT_ID)

__EOF__
chmod 644 /usr/local/include/Makefile.rds


##
## Github Authorized Keys Setup
##

# Do not require password for users in sudo group 
echo '%sudo  ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/group

mkdir /etc/secrets
chmod 700 /etc/secrets
cat <<"__EOF__" > /etc/secrets/github-authorized-keys
GITHUB_API_TOKEN=${github_api_token}
GITHUB_ORGANIZATION=${github_organization}
GITHUB_TEAM=${github_team}
SYNC_USERS_GID=500
SYNC_USERS_GROUPS=sudo
SYNC_USERS_SHELL=/bin/bash
SYNC_USERS_ROOT=/
SYNC_USERS_INTERVAL=300
LISTEN=:301
INTEGRATE_SSH=true
LINUX_USER_ADD_TPL=/usr/sbin/useradd --create-home --password '*' --shell {shell} {username}
LINUX_USER_ADD_WITH_GID_TPL=/usr/sbin/useradd --create-home --password '*' --shell {shell} --group {group} {username}
LINUX_USER_ADD_TO_GROUP_TPL=/usr/sbin/usermod --append --groups {group} {username}
LINUX_USER_DEL_TPL=/usr/sbin/userdel {username}
SSH_RESTART_TPL=/bin/systemctl restart sshd.service
AUTHORIZED_KEYS_COMMAND_TPL=/usr/bin/authorized-keys
__EOF__

cat <<"__EOF__" > /etc/systemd/system/github-authorized-keys.service
[Unit]
Description=GitHub Authorized Keys

Requires=network-online.target
After=network-online.target

[Service]
User=root
TimeoutStartSec=0
EnvironmentFile=/etc/secrets/%p
ExecStartPre=-/usr/bin/curl -Lso /usr/bin/authorized-keys https://raw.githubusercontent.com/cloudposse/github-authorized-keys/master/contrib/authorized-keys
ExecStartPre=-/bin/chmod 755 /usr/bin/authorized-keys
ExecStartPre=-/usr/bin/curl -Lso /usr/bin/github-authorized-keys https://github.com/cloudposse/github-authorized-keys/releases/download/1.0.3/github-authorized-keys_linux_amd64
ExecStartPre=-/bin/chmod 755 /usr/bin/github-authorized-keys
ExecStart=/usr/bin/github-authorized-keys
TimeoutStopSec=20s
Restart=always
RestartSec=10s
__EOF__
systemctl daemon-reload
systemctl start github-authorized-keys.service


##
## EFS Setup
##
EFS_MOUNT_DIR="/efs"
EFS_HOST="${efs_host}"

until host $EFS_HOST
do
  echo "Waiting for $EFS_HOST to become available ..."
  sleep 1;
done

echo "Mounting EFS filesystem $EFS_HOST to directory $EFS_MOUNT_DIR ..."

echo 'Stopping NFS ID Mapper...'
service rpcidmapd status &> /dev/null
if [ $? -ne 0 ] ; then
    echo 'rpc.idmapd is already stopped!'
else
    service rpcidmapd stop
    if [ $? -ne 0 ] ; then
        echo 'ERROR: Failed to stop NFS ID Mapper!'
        exit 1
    fi
fi

echo 'Checking if EFS mount directory exists...'
if [ ! -d $EFS_MOUNT_DIR ]; then
    echo "Creating directory $EFS_MOUNT_DIR ..."
    mkdir -p $EFS_MOUNT_DIR
    if [ $? -ne 0 ]; then
        echo 'ERROR: Directory creation failed!'
        exit 1
    fi
    chmod 777 $EFS_MOUNT_DIR
    if [ $? -ne 0 ]; then
        echo 'ERROR: Permission update failed!'
        exit 1
    fi
else
    echo "Directory $EFS_MOUNT_DIR already exists!"
fi

mountpoint -q $EFS_MOUNT_DIR
if [ $? -ne 0 ]; then
    echo "mount -t nfs4 -o nfsvers=4.1 $EFS_HOST:/ $EFS_MOUNT_DIR"
    mount -t nfs4 -o nfsvers=4.1 $EFS_HOST:/ $EFS_MOUNT_DIR
    if [ $? -ne 0 ] ; then
        echo 'ERROR: Mount command failed!'
        exit 1
    fi
else
    echo "Directory $EFS_MOUNT_DIR is already a valid mountpoint!"
fi

chmod 777 $EFS_MOUNT_DIR
if [ $? -ne 0 ]; then
  echo 'ERROR: Permission update failed!'
  exit 1
fi

echo 'EFS mount complete.'

##
## Append addition user-data script
##

${additional_user_data_script}

