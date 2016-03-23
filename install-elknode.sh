#!/bin/bash

## SSL CHECK ------------------------------------------------------------------------------------
echo "SSL SETUP CHECK: STARTING SSL SETUP CHECK"

# check ssl setup: test if truststore exists
if [ ! -f /tmp/elkinstalldir/ssl/truststore.jks ] 
then
	echo "SSL SETUP CHECK: ERROR: The required file \"ssl/truststore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi

# check ssl setup: test if keystore exists
if [ ! -f /tmp/elkinstalldir/ssl/$(hostname)-keystore.jks ] 
then
	echo "SSL SETUP CHECK: ERROR: The required file \"ssl/$(hostname)-keystore.jks\" does not exist."
	echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
	exit;
fi
echo "SSL SETUP CHECK: CHECK FINISHED. NO PROBLEMS DETECTED"
## SSL CHECK END --------------------------------------------------------------------------------


# install the required puppet modules and dependencies
sudo puppet module install elasticsearch-elasticsearch --version 0.10.3
sudo puppet module install puppet/collectd

# install elasticsearch node via puppet
sudo puppet apply --debug --modulepath=/etc/puppet/modules --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml -e "include elastic_cluster"

# run cleanup and finalization script
source /tmp/elkinstalldir/installation/finish-install-elknode.sh