#!/bin/bash

# install the required puppet modules and dependencies

sudo puppet module install puppetlabs/apt
sudo puppet module install puppetlabs/stdlib
sudo puppet module install puppetlabs-mongodb
sudo puppet module install graylog2-graylog2 --ignore-dependencies


# install elasticsearch node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-graylog.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
