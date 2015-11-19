#! /bin/bash

# This will install logstash forwarder binaries

wget https://download.elastic.co/logstash-forwarder/binaries/logstash-forwarder-0.4.0-1.x86_64.rpm
rpm -ivH logstash-forwarder-0.4.0-1.x86_64.rpm

# Logs for logstash-forwarder will be in /var/log/logstash-forwarder/

https://download.elastic.co/logstash-forwarder/binaries/logstash-forwarder-0.4.0-1.x86_64.rpm
rpm -ivH logstash-forwarder-0.4.0-1.x86_64.rpm 

# Logs for logstash-forwarder will be in /var/log/logstash-forwarder/

# copy the logstash-forwarder.crt file from prod server to cloud server

# make below changes under network section 

#”servers": [ “<prod server ip>:6782" ], 
#”ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"

# make below changes under files section

#      "paths": [
        # single paths are fine
        #"/var/log/messages",
        # globs are fine too, they will be periodically evaluated
        # to see if any new files match the wildcard.
   #     "/var/log/httpd/access*"
  #    ],
 #     "fields": { "type": "apache" }

      # A dictionary of fields to annotate on each event.
      #"fields": { "type": "syslog" }
 #   }

# start the logstash forwarded as shown below
#/etc/init.d/logstash-forwarder start -f /etc/logstash-forwarder.conf
