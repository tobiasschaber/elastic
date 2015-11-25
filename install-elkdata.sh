#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";

# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# add the rpm repositories which contain the required packages
rpm -ivh https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.0.0/elasticsearch-2.0.0.rpm
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# install puppet and git
yum install puppet -y
yum install git -y

# install all puppet modules which are required for the following installation
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppetlabs-java
sudo puppet module install ceritsc-yum
sudo puppet module install elasticsearch-elasticsearch
sudo puppet module install maestrodev-wget

# install elasticsearch master node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-elknode.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml

sudo service elasticsearch-es-01 restart
