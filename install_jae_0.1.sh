#!/bin/bash


##########################################################

#title           :install_jae_0.1.sh
#description     :This script will install Java 1.7, ELK stack. Login as root to install this script.
#author          :Sigmaways - Ram Rengamani
#date            :20151102
#application     :JAE
#version         :0.1
#usage           :./install_jae_0.1.sh
#notes           :Installs Java 1.7, httpd, elastic search, logstash and Kibana for log analytics.
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
service httpd start
echo "Installing Python 2.7, NLTK and other machine learning libraries..."
sleep 5
installPythonDependencies

}

##########################################################

### installPythonDependencies

##########################################################

installPythonDependencies() {

yum -y update
yum groupinstall -y 'development tools'

yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel lapack lapack-devel blas blas-devel freetype-devel libpng-devel xz-libs


wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz
xz -d Python-2.7.6.tar.xz
tar -xvf Python-2.7.6.tar

cd Python-2.7.6

./configure --prefix=/usr/local
make
make altinstall
export PATH="/usr/local/bin:$PATH"

wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz
tar -xvf setuptools-1.4.2.tar.gz

cd setuptools-1.4.2

python2.7 setup.py install

curl https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py | python2.7 -

pip install nltk
python2.7 -m nltk.downloader all
pip install numpy
pip install scipy
pip install scikit-learn
pip install pandas
pip install tornado
pip install matplotlib
pip install lifelines
pip install pyenchant
pip install statistics

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

