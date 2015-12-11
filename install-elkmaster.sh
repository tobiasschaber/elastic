#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# run the preparation scripts for elasticsearch node installation
chmod +x $ELKINSTALLDIR/installation/*.sh
source $ELKINSTALLDIR/installation/prepare-java.sh
source $ELKINSTALLDIR/installation/prepare-install-elknode.sh

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

source $ELKINSTALLDIR/installation/finish-install-elknode.sh
