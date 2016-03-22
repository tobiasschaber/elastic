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

# check if the stunnel_full.pem is required and if yes, if it exists
if grep -q -e "\s*installlogstash::redis_ssl:\strue" "/tmp/elkinstalldir/hiera/nodes/$(hostname).yaml";
then
    if [ ! -f /tmp/elkinstalldir/ssl/stunnel_full.pem ]
    then
	    echo "SSL SETUP CHECK: ERROR: The required file \"ssl/stunnel_full.pem\" does not exist."
	    echo "Please run \"prepare-ssl.sh\" before booting any vagrant boxes or insert your own jks files!"
        exit
    fi
fi
## SSL CHECK END --------------------------------------------------------------------------------

# install the required puppet modules and dependencies
sudo puppet module install elasticsearch-logstash
sudo puppet module install arusso-stunnel

# install logstash via puppet
# parser=future is required to make use of each{} function
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-logstash.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
