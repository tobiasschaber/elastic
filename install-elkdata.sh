#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# run the preparation script for elasticsearch node installation
chmod +x $ELKINSTALLDIR/installation/*.sh
source $ELKINSTALLDIR/installation/prepare-install-elknode.sh

# install elasticsearch master node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-elknode.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml

source $ELKINSTALLDIR/installation/finish-install-elknode.sh
