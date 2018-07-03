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

## enable aws dynamic inventory
##   https://aws.amazon.com/jp/blogs/apn/getting-started-with-ansible-and-dynamic-amazon-ec2-inventory-management/

curl -L https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py -O \
    && chmod 755 ec2.py \
    && mv ec2.py /usr/local/bin/

curl -L https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini -O \
    && chmod 755 ec2.ini \
    && sed -i -e "s/^vpc_destination_variable = .*$/vpc_destination_variable = private_ip_address/" ec2.ini \
    && sed -i -e "s/^cache_max_age = .*$/cache_max_age = 0/" ec2.ini \
    && mv ec2.ini /usr/local/etc/

cat <<EOF > /etc/profile.d/ec2.sh
export ANSIBLE_INVENTORY=/usr/local/bin/ec2.py
export EC2_INI_PATH=/usr/local/etc/ec2.ini
EOF

source /etc/profile.d/ec2.sh

