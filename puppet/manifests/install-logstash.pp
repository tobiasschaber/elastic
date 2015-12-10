#
#
# this file performs the installation of logstash
#
# author: Tobias Schaber (codecentric AG)
#
class installlogstash {

	# install logstash via the puppet module
	class { 'logstash':
		manage_repo => true,
		ensure => "present",
		status => "running",
	}

        $logstash_user = hiera('logstash::logstash_user', 'logstash')
        $logstash_group = hiera('logstash::logstash_group', 'logstash')
        
        $elk_config  = hiera('elasticsearch::config')
	$logstash_elkuser = hiera('installelknode::configureshield::defaultadminname')
	$logstash_elkpass = hiera('installelknode::configureshield::defaultadminpass')
        $truststore_pass = $elk_config['shield']['ssl']['truststore.password'] 

	# copy a config file based on a template
	# attention! the path to this file depends on the git clone target directory and may be adjusted!
	logstash::configfile { 'central' :
		content => template("/tmp/elkinstalldir/puppet/templates/logstash-central.conf.erb"),
		order => 10
	}

        # add jks truststore
        file { '/etc/logstash/truststore.jks' :
                source => "/tmp/elkinstalldir/ssl/truststore.jks",
		owner => $logstash_user,
		group => $logstash_group,
                mode => "0755",
        }


} 

# trigger puppet execution
include installlogstash
