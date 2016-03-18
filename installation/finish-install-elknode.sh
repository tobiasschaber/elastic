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

        major_version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | awk -F. '{print $1}')

        # use service command on CentOS/RHEL 6
        if [ $major_version == 6 ]
            then
            sudo service elasticsearch-es-01 restart

        # use systemctl command on CentOS/RHEL 7
        else if [ $major_version == 7 ]
            then
            sudo systemctl restart elasticsearch-es-01
        fi
    fi
fi
