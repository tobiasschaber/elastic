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
echo "SSL SETUP CHECK: CHECK FINISHED. NO PROBLEMS DETECTED"
## SSL CHECK END --------------------------------------------------------------------------------


# install the required puppet modules and dependencies
sudo puppet module install elasticsearch-logstash

# install logstash via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-logstash.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
