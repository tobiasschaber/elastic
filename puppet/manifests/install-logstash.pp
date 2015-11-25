#
#
# this file performs the installation of logstash
#
# author: Tobias Schaber (codecentric AG)
#
class installlogstash {

	# install logstash via the puppet module
	class { 'logstash':
		logstash_user => logstash,
		logstash_group => logstash,
		manage_repo => true,
		repo_version => '2.0',
		ensure => "present",
		status => "running",
		java_install => true,
		
	}

	# copy a config file based on a template
	# attention! the path to this file depends on the git clone target directory and may be adjusted!
	logstash::configfile { 'central' :
		content => template("/tmp/elkinstalldir/puppet/templates/logstash-central.conf.erb"),
		order => 10
	}
} 

# trigger puppet execution
include installlogstash
