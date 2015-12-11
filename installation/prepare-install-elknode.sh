#!/bin/bash

# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

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



# add the rpm repository for puppet
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

# install puppet and git
yum install puppet -y



# download the java rpm file into a shared temporary location to avoid multiple downloads
if [ ! -f "$ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm" ]
then
        echo "Downloading Java"
        # download the oracle java 8 rpm
        sudo wget -q --no-cookies -O $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.rpm"
fi


# register the oracle java 8 rpm in yum
sudo rpm -ivh $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm

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


