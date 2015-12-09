#!/bin/bash

# install the required repositories and packages via yum
curl http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm -o /tmp/puppetlabs-release-el-7.noarch.rpm
rpm -ivh /tmp/puppetlabs-release-el-6.noarch.rpm

# install puppet and git
yum install puppet -y
yum install git -y

# install the required puppet modules and dependencies
puppet module install puppetlabs-stdlib
puppet module install elasticsearch-logstashforwarder

# logstash-forwarder must be installed by hand because
# the puppet installer will fail, because it will try to
# execute this command with a user which has http_proxy 
# not set
yum -d 0 -e 0 -y list logstash-forwarder
yum -d 0 -e 0 -y install logstash-forwarder

# change into installation temp directory
cd /tmp

# checkout the logstash-forwarder installer or update if already checked out
if [ ! -d "/tmp/elastic" ]; 
	then 
		# if not existing, clone it
		git clone git@git.services.emea.dir:log/elastic.git
	else 
		# if already existing, get the latest version by pulling
		cd /tmp/elastic
		git pull
fi


# copy the ssl ca chain into the target directory
sudo cp /tmp/elastic/puppet/files/logforwarderca.crt /etc/pki/tls/certs/logforwarderca.crt
sudo cp /tmp/elastic/puppet/files/logforwarder.crt /etc/pki/tls/certs/logforwarder.crt

# run the installation script via puppet
sudo puppet apply --debug sudo puppet apply --debug /vagrant/puppet/manifests/install-logstash-forwarder.pp
