#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";


# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# run the preparation script for java
source $ELKINSTALLDIR/installation/prepare-java.sh

# run the preparation script for puppet
source $ELKINSTALLDIR/installation/prepare-puppet.sh

# install all puppet modules which are required for the following installation
sudo puppet module install puppetlabs-apt
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install ceritsc-yum
sudo puppet module install maestrodev-wget

sudo rm -r /etc/puppet/modules/elastic_cluster
sudo cp -r $ELKINSTALLDIR/puppet /etc/puppet/modules/elastic_cluster

echo "finished preparation"
