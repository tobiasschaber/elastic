#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";


# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# run the preparation scripts for java
source $ELKINSTALLDIR/installation/prepare-java.sh

# add the rpm repository for puppet
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

# install puppet and git
yum install puppet -y

# install all puppet modules which are required for the following installation
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install ceritsc-yum
sudo puppet module install maestrodev-wget
