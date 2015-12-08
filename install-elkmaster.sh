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

# download the oracle java 8 rpm
sudo wget -q --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.rpm"

# register the oracle java 8 rpm in yum
sudo rpm -ivh jdk-8u65-linux-x64.rpm

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

# install kibana4 via puppet
sudo puppet apply /tmp/elkinstalldir/puppet/manifests/install-kibana.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml


#####################################################################################################################################################
# WORKAROUND: FIXES ACCESS DENIED PROBLEM ON KIBANA BABELCACHE FILE WHICH IS OWNED BY ROOT
#####################################################################################################################################################
sudo chown kibana:kibana /opt/kibana4/optimize/.babelcache.json

# restart ELK service
sudo systemctl restart elasticsearch-es-01


