#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# check ssl setup: test if truststore exists
if [ ! -f $ELKINSTALLDIR/ssl/truststore.jks ] 
then
	echo "ERROR: The required file \"ssl/truststore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi

# check ssl setup: test if keystore exists
if [ ! -f $ELKINSTALLDIR/ssl/$(hostname)-keystore.jks ] 
then
	echo "ERROR: The required file \"ssl/$(hostname)-keystore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi

# add the rpm repository for puppet
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

# install puppet and git
yum install puppet -y

# install all puppet modules which are required for the following installation
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install ceritsc-yum
sudo puppet module install elasticsearch-elasticsearch
sudo puppet module install maestrodev-wget


#####################################################################################################################################################
# WORKAROUND: the currently released elasticsearch puppet module service start script is not 2.X ready so we check out the not yet released one
#####################################################################################################################################################
sudo rm /etc/puppet/modules/elasticsearch/templates/etc/init.d/elasticsearch.systemd.erb
sudo wget https://raw.githubusercontent.com/elastic/puppet-elasticsearch/master/templates/etc/init.d/elasticsearch.systemd.erb -P /etc/puppet/modules/elasticsearch/templates/etc/init.d
# WORKAROUND ENDED ##################################################################################################################################

# install elasticsearch master node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-elknode.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml


#####################################################################################################################################################
# WORKAROUND: IT SEEMS THAT WITH CENTOS7 THE PKCS PROVIDER IS DISABLED AND SHOULD BE ENABLED
#####################################################################################################################################################
#sudo sed -i 's/#security.provider.10/security.provider.10/g' /usr/lib/jvm/jre-1.8.0/lib/security/java.security

sudo systemctl restart elasticsearch-es-01
