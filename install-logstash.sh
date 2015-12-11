#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# run the preparation script for logstash
chmod +x $ELKINSTALLDIR/installation/*.sh
source $ELKINSTALLDIR/installation/prepare-java.sh

# check ssl setup: test if truststore exists
if [ ! -f $ELKINSTALLDIR/ssl/truststore.jks ] 
then
	echo "ERROR: The required file \"ssl/truststore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi

# install the required repositories and packages via yum
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm


# install puppet and git
yum install puppet -y

# install the required puppet modules and dependencies
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install elasticsearch-logstash

# run the installation script via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-logstash.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
