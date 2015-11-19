#!/bin/bash

echo "Caution!!. This will remove httpd, owncloud and php55 related components." 
echo
echo "Do you wish to continue? [y/n]"
read choice

if [ $choice == "y" ] 
then
   yum -y remove php55w php55w-opcache
   yum -y remove owncloud
   yum -y remove httpd 
else
   echo "Great Decision!!"
fi
