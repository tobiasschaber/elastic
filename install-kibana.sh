#!/bin/bash




# install kibana4 via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-kibana.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml


#####################################################################################################################################################
# WORKAROUND: FIXES ACCESS DENIED PROBLEM ON KIBANA BABELCACHE FILE WHICH IS OWNED BY ROOT
#####################################################################################################################################################
sudo chown kibana:kibana /opt/kibana4/optimize/.babelcache.json

