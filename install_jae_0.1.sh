#!/bin/bash


##########################################################

#title           :install_jae_0.1.sh
#description     :This script will install Java 1.7, Own cloud, ELK stack. Login as root to install this script.
#author          :Sigmaways - Ram Rengamani
#date            :20151102
#application     :JAE
#version         :0.1
#usage           :./install_jae_0.1.sh
#notes           :Installs Java 1.7, httpd, own cloud, elastic search, logstash and Kibana for log analytics.
#OS_version      :Cent OS 6.7-release

##########################################################


#- You have to change the IP-address to the IP of the central server in configuration marked with [ip-for-central-server].

#- You may have to change the Elasticsearch network.host parameter to the internal IP of your server to use eg. GET on the URL from Kibana.

#- You may have to change the Kibana elasticsearch parameter to the actual URL with your internal IP to connect probably to the interface.


##########################################################

### MAIN

##########################################################



main() {

dependencies

owncloud

elasticsearch

logstash

generateSecurityCertificates

kibana


}
##########################################################

### DEPENDENCIES

##########################################################


dependencies() {

echo ""

echo "Installing Java 1.7 and httpd …"

sleep 5

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6*.rpm
yum -y install java-1.7.0-openjdk httpd

    rpm --import https://download.owncloud.org/download/repositories/stable/CentOS_6/repodata/repomd.xml.key
    wget http://download.owncloud.org/download/repositories/stable/CentOS_6/ce:stable.repo -O /etc/yum.repos.d/ce:stable.repo
    yum clean expire-cache
    rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

service httpd start

}

##########################################################

### owncloud

##########################################################

owncloud() {

echo "Installing php 55 and own cloud…"
sleep 5
    yum -y install php55w php55w-opcache
    yum -y install owncloud
    service httpd restart

}

##########################################################

### ELASTICSEARCH

##########################################################


elasticsearch() {

echo ""

echo "Installing Elasticsearch…"

sleep 5

cat <<EOF >> /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-2.0]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF
yum -y install elasticsearch

sed -i '/network.host/c\network.host: localhost' /etc/elasticsearch/elasticsearch.yml

sed -i '/discovery.zen.ping.multicast.enabled/c\discovery.zen.ping.multicast.enabled: false' /etc/elasticsearch/elasticsearch.yml

sed -i '/cluster.name/c\cluster.name: elasticsearch' /etc/elasticsearch/elasticsearch.yml

chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/ /var/log/elasticsearch/

service elasticsearch start

}



##########################################################

### LOGSTASH

##########################################################



logstash() {

echo ""

echo "Installing Logstash…"

sleep 5

cat <<EOF >> /etc/yum.repos.d/logstash.repo
[logstash-2.0]
name=logstash repository for 2.x packages
baseurl=http://packages.elasticsearch.org/logstash/2.0/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF

yum -y install logstash

cat <<EOF >> /etc/logstash/conf.d/indexer.conf
input {
  lumberjack {
     port => 6782
     ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
     ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
     type => "lumberjack"
  }
}
output {
  stdout { }
  elasticsearch { hosts => "localhost" }
}
EOF

chown -R logstash:logstash /var/lib/logstash/ /var/log/logstash/

service logstash start -f /etc/logstash/conf.d/indexer.conf

}

##########################################################

### Generate Security Certificates

##########################################################

generateSecurityCertificates() {
  
echo "Installing Security certificates for log forwarder…"
sleep 5
    mkdir -p /etc/pki/tls/certs
    sed -i "s/\[ v3_ca \]/\[\ v3_ca \]\n subjectAltName=IP:`hostname -i`/" /etc/pki/tls/openssl.cnf

    openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt

}

##########################################################

### KIBANA

##########################################################



kibana() {

echo ""

echo "Installing Kibana…"

sleep 5


groupadd -g 1005 kibana
useradd -u 1005 -g 1005 kibana

wget https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz

tar xvf kibana-4.2.0-linux-x64.tar.gz

sed -i "s/host: \"0.0.0.0\"/host: \"`hostname -i`\"/" kibana-4.2.0-linux-x64/config/kibana.yml


mkdir -p /opt/kibana
cp -R kibana-4.2.0-linux-x64/* /opt/kibana/

chown -R kibana: /opt/kibana

cd /etc/init.d && sudo curl -o kibana https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/fc5025c3fc499ad8262aff34ba7fde8c87ead7c0/kibana-4.x-init
cd /etc/default && sudo curl -o kibana https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/fc5025c3fc499ad8262aff34ba7fde8c87ead7c0/kibana-4.x-default

chmod +x /etc/init.d/kibana

service kibana start

}

##########################################################

### INIT

##########################################################



echo "This will install httpd, owncloud, elastic search 2.0, logstash 2.0 Kibana 4.1.1"
echo "Do you wish to continue [y/n] ?"
read choice
if [ $choice == "y" ]
then
    main
    echo
    echo "Installation completed successfully!!. Time to customize the config files of owncloud and ELK stack... Good Luck!!"
else
    echo "Thanks for trying. see you next time.."
fi

