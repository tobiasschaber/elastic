#!/bin/bash

# graylog requires elasticsearch < 2.* and no authentication.
# thats why shield plugin will not be installed an all ssl is disabled.


# install the required puppet modules and dependencies

sudo puppet module install puppetlabs/apt
sudo puppet module install puppetlabs/stdlib
sudo puppet module install puppetlabs-mongodb
sudo puppet module install graylog2-graylog2 --ignore-dependencies


# install elasticsearch node via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-graylog.pp  --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
