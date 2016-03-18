#!/bin/bash

# This script will perform the installation of the required puppet
# modules.



# for debian systems, there is a file under /etc/debian_version
if [ -f /etc/debian_version ]
    then
    wget http://apt.puppetlabs.com/puppetlabs-release-trusty.deb
    sudo dpkg -i puppetlabs-release-trusty.deb
    #sudo apt-get install puppet
fi


# for RHEL/CentOS systems, there is a file under /etc/redhat-release
if [ -f /etc/redhat-release ]
    then
        # get the major centos/rhel version
        major_version=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | awk -F. '{print $1}')

        # add the rpm repository for puppet
        rpm -ivh "http://yum.puppetlabs.com/puppetlabs-release-el-$major_version.noarch.rpm"

        # install puppet and git
        yum install puppet -y
fi