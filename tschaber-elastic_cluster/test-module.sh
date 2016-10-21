#!/bin/bash


# sudo apt-get install ruby-dev -> mkfm fehler beheben!
# sudo gem install ...
#    puppet
#    rspec-puppet
#    puppet-lint
#    puppetlabs_spec_helper
#    rspec-puppet-facts

echo "------------------------------------------------------"
echo "performing lint check..."
echo "------------------------------------------------------"
rake lint


echo "------------------------------------------------------"
echo "performing spec check..."
echo "------------------------------------------------------"

rake spec

