#!/bin/bash
#
# Setup AWX with docker-compose (no proxy env)
# 
#  document: https://github.com/ansible/awx/blob/devel/INSTALL.md
#  checked: 2018/06/07
# 

## define check_return
check_return(){
    [ $? != 0 ] && echo "$1" && exit 1
}

## setup EPEL repository
cat <<EOF > /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
baseurl=http://ftp.riken.jp/Linux/fedora/epel/7/x86_64/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF

## install packages
yum -y install ansible docker docker-python docker-compose make git nodejs npm python2-ansible-tower-cli
check_return "ERROR: failed to install packages, exit."

## disable selinux
setenforce 0
sed -i -e "s/^SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

## enable docker
systemctl start docker
systemctl enable docker
check_return "ERROR: failed to enable docker, exit."

## clone awx repository
pushd /var/tmp
git clone https://github.com/ansible/awx-logos
git clone https://github.com/ansible/awx
check_return "ERROR: failed to clone awx repository, exit."

## change parameters
mkdir -p /var/docker/awx-postgres

cat <<EOF >> awx/installer/inventory
awx_official=true
postgres_data_dir=/var/docker/awx-postgres
host_port=80
use_docker_compose=true
docker_compose_dir=/var/lib/awx
pg_username=awx
pg_password=awxpass
pg_database=awx
pg_port=5432
project_data_dir=/var/lib/awx/projects
EOF

## build
cd awx/installer
ansible-playbook -i inventory install.yml
check_return "ERROR: failed to install AWX, exit."

## enable auto boot
#sed -i -e "s/ restart: .*$/ restart: always/" /var/lib/awx/docker-compose.yml

## finished
cat <<EOF
------
AWX installed succesfully !!
check your container's log

 # docker logs -f awx_task_1

EOF

popd


## memo: upgrade AWS
##  # cd /var/lib/awx
##  # docker-compose pull && docker-compose up --force-recreate

