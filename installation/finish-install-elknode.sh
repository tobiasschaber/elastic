#!/bin/bash

# This script will be executed after the installation process of an
# elasticsearch node has finished.



# for debian systems, use service
if [ -f /etc/debian_version ]
    then
    sudo service elasticsearch-es-01 restart
fi


# for RHEL/CentOS systems, use systemctl
if [ -f /etc/redhat-release ]
    then
        sudo systemctl restart elasticsearch-es-01
fi


