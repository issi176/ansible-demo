#!/bin/bash
#
# Setup ansible for RHEL7/CentOS7
# checked: 2018/06/07
# 

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
yum -y install ansible python2-pip cowsay 
pip install boto3 
pip install boto 
pip install 'jinja2>=2.8'
pip install zabbix-api

