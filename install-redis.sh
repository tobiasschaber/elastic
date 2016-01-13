#!/bin/bash



# install the required puppet modules and dependencies
sudo puppet module install arioch-redis

# install redis via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-redis.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml

