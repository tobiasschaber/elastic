#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# install the required repositories and packages via yum
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm


# install puppet and git
yum install puppet -y

# install the required puppet modules and dependencies
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install elasticsearch-logstash

# run the installation script via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-logstash.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
