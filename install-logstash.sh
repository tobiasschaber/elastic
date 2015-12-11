#!/bin/bash

# install the required puppet modules and dependencies
sudo puppet module install elasticsearch-logstash

# install logstash via puppet
sudo puppet apply --debug /tmp/elkinstalldir/puppet/manifests/install-logstash.pp --hiera_config=/tmp/elkinstalldir/hiera/hiera.yaml
