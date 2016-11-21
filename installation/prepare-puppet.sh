#!/bin/bash

# This script will perform the installation of puppet



# for debian systems, there is a file under /etc/debian_version
if [ -f /etc/debian_version ]
    then
    sudo apt-get -y install puppet
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

# install the elastic-cluster puppet module
puppet module install tschaber-elastic_cluster