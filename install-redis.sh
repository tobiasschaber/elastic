#!/bin/bash

## SSL CHECK ------------------------------------------------------------------------------------

# check if the stunnel_full.pem is required and if yes, if it exists
if grep -q -e "\s*installredis::redis_ssl:\strue" "/tmp/elkinstalldir/hiera/nodes/$(hostname).yaml";
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
sudo puppet module install arioch-redis
sudo puppet module install arusso-stunnel


# install redis via puppet
sudo puppet apply --debug --modulepath=/etc/puppet/modules --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml -e "include elastic_cluster"

