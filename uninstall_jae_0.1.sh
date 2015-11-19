#!/bin/bash

##########################################################

#title           :uninstall_jae_0.1.sh
#description     :This script will remove Java 1.7, Own cloud, ELK stack. Login as root to install this script.
#author          :Sigmaways - Ram Rengamani
#date            :20151102
#application     :JAE
#version         :0.1
#usage           :./uninstall_jae_0.1.sh
#notes           :Removes Java 1.7, httpd, own cloud, elastic search, logstash and Kibana for log analytics.
#OS_version      :Cent OS 6.7-release

##########################################################

echo "You are about to remove all components of JAE 0.1. Do you wish to continue [y/n]?"
read choice

if [ $choice == "y" ]
then
   service kibana stop
   service elasticsearch stop
   service logstash stop
   service httpd stop
   yum -y remove java-1.7.0-openjdk httpd elasticsearch kibana logstash php55w php55w-opcache httpd
   rm -rf /etc/elasticsearch/ /etc/logstash
   userdel kibana
   rm -rf /var/log/kibana.log /var/log/logstash/
   rm -rf kibana-4.2.0-linux-x64*
   rm -rf epel-release-6-8.noarch.rpm*
   rm -rf /opt/kibana/ /etc/init.d/kibana
   rm -rf /etc/pki/tls/certs/logstash-forwarder.crt
   rm -rf /etc/pki/tls/private/logstash-forwarder.key
   yum -y remove zlib-dev openssl-devel sqlite-devel bzip2-devel lapack lapack-devel blas blas-devel freetype-devel libpng-devel xz-libs
   rm -rf Python-2.7.6.tar.xz Python-2.7.6
   rm -rf setuptools-1.4.2.tar.gz setuptools-1.4.2
   pip uninstall nltk numpy scipy scikit-learn pandas tornado matplotlib lifelines pyenchant statistics
   rm -rf /root/nltk_data
   yum -y remove git
   rm -rf JAE0.1 "JAE 0.1.tar.gz" "JAE 0.1"
else
   echo "Good Decision.. See you next time.."
fi
