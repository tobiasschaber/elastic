#
#
# this class installs the logstash forwarder and 
# adds some files to be monitored and forwarded.
# before starting the installation, adjust the 
# required files which should be monitored as
# needed on the target system. remove all files
# which do not exist on the target system.
#
# author: Tobias Schaber (codecentric AG)
#
class elastic_cluster::facets::logstash_forwarder_node {

	# install the logstash forwarder.
	# tell him the logstash server url to use
	class { 'logstashforwarder':
		servers  => ['10.0.3.111:15102'],
		manage_repo => true,
#		ssl_key  => '/etc/ssl/logforwarder.key',
		ssl_ca   => '/etc/ssl/certs/logforwarderca.crt',
#		ssl_cert => '/etc/ssl/certs/logforwarder.crt',
	}

	# configure the syslog to be monitored
	logstashforwarder::file { 'syslog':
		paths  => [
			'/var/log/syslog',
			'/var/log/messages' 
		],
		fields => { 'type' => 'syslog'}
	}

	# configure the icinga log to be monitored
	logstashforwarder::file { 'icinga':
		paths  => [ 
			'/var/log/icinga/icinga.log'
		],
		fields => { 'type' => 'icinga'}
	}
	
	# configure the httpd access logs to be monitored
	logstashforwarder::file { 'httpdaccess':
		paths  => [ 
			'/var/log/httpd/access_log*',
			'/var/log/httpd/ssl_access_log*'
		],
		fields => { 'type' => 'httpd-access'}
	}
	
	# configure the httpd error logs to be monitored
	logstashforwarder::file { 'httpderror':
		paths  => [ 
			'/var/log/httpd/error_log*',
			'/var/log/httpd/ssl_error_log*'
		],
		fields => { 'type' => 'httpd-error'},
	}
	
	# configure the secure log to be monitored
	logstashforwarder::file { 'secure':
		paths  => [ 
			'/var/log/secure*'
		],
		fields => { 'type' => 'linux-secure'},
	}
}
