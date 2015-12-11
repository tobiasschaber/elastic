#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";


# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# run the preparation scripts for java
source $ELKINSTALLDIR/installation/prepare-java.sh


## SSL CHECK ------------------------------------------------------------------------------------
echo "SSL SETUP CHECK: STARTING SSL SETUP CHECK"

# check ssl setup: test if truststore exists
if [ ! -f $ELKINSTALLDIR/ssl/truststore.jks ] 
then
	echo "SSL SETUP CHECK: ERROR: The required file \"ssl/truststore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi

# check ssl setup: test if keystore exists
if [ ! -f $ELKINSTALLDIR/ssl/$(hostname)-keystore.jks ] 
then
	echo "SSL SETUP CHECK: ERROR: The required file \"ssl/$(hostname)-keystore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi
echo "SSL SETUP CHECK: CHECK FINISHED. NO PROBLEMS DETECTED"
## SSL CHECK END --------------------------------------------------------------------------------

# add the rpm repository for puppet
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

# install puppet and git
yum install puppet -y

# install all puppet modules which are required for the following installation
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install ceritsc-yum
sudo puppet module install maestrodev-wget
