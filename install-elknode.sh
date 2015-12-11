#!/bin/bash

# install the required puppet modules and dependencies
sudo puppet module install elasticsearch-elasticsearch

#####################################################################################################################################################
# WORKAROUND: the currently released elk puppet module systemctl script is not 2.X ready so we check out the not yet released one
#####################################################################################################################################################
sudo rm /etc/puppet/modules/elasticsearch/templates/etc/init.d/elasticsearch.systemd.erb
sudo wget https://raw.githubusercontent.com/elastic/puppet-elasticsearch/master/templates/etc/init.d/elasticsearch.systemd.erb -P /etc/puppet/modules/elasticsearch/templates/etc/init.d ##################################################################################################################################



# install elasticsearch node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-elknode.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml

# run cleanup and finalization script
source /tmp/elkinstalldir/installation/finish-install-elknode.sh
