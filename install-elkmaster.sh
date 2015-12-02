#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# add the rpm repository for puppet
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# install puppet and git
yum install puppet -y

# install all puppet modules which are required for the following installation
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install ceritsc-yum
sudo puppet module install elasticsearch-elasticsearch
sudo puppet module install maestrodev-wget

# install elasticsearch master node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-elknode.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml

# install kibana4 via puppet
sudo puppet apply /tmp/elkinstalldir/puppet/manifests/install-kibana.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml


# TEMPORARY FIX!
# FIXES ACCESS DENIED PROBLEM ON KIBANA BABELCACHE FILE WHICH IS OWNED BY ROOT
sudo chown kibana:kibana /opt/kibana4/optimize/.babelcache.json


# restart ELK service
sudo service elasticsearch-es-01 restart


