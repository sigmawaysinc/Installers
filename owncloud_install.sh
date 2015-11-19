#!/bin/bash

echo "This will install httpd, own cloud and php55 related components. Do you wish to continue? [y/n] "
read choice

if [ $choice == "y" ] 
then
    rpm --import https://download.owncloud.org/download/repositories/stable/CentOS_6/repodata/repomd.xml.key
    wget http://download.owncloud.org/download/repositories/stable/CentOS_6/ce:stable.repo -O /etc/yum.repos.d/ce:stable.repo
    yum clean expire-cache
    rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
    yum -y install httpd
    yum -y install php55w php55w-opcache
    yum -y install owncloud
    service httpd restart
else
    echo "Thanks for trying.See you next time!!"
fi
