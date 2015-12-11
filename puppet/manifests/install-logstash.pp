#
#
# this file performs the installation of logstash
#
# author: Tobias Schaber (codecentric AG)
#
class installlogstash {

        $elk_config       = hiera('elasticsearch::config')
        $truststore_pass  = $elk_config['shield']['ssl']['truststore.password']
        $logstash_elkuser = hiera('installelknode::configureshield::defaultadminname', 'logstash')
        $logstash_elkpass = hiera('installelknode::configureshield::defaultadminpass', 'logstash')

        # enable ssl between kibana and elasticsearch?
        $enableelkssl   = $elk_config['shield']['http.ssl']

	# install logstash via the puppet module
	class { 'logstash':
		manage_repo => true,
		ensure => "present",
		status => "running",
	}

	# copy a config file based on a template
	# attention! the path to this file depends on the git clone target directory and may be adjusted!
	logstash::configfile { 'central' :
		content => template("/tmp/elkinstalldir/puppet/templates/logstash-central.conf.erb"),
		order => 10
	} 

        ->

	# perform the configuration steps
	class { 'installlogstash::configlogstash' :
                enablessl => $enableelkssl,
                logstash_user => hiera('logstash::logstash_user'),
                logstash_group => hiera('logstash::logstash_group'),
	}
} 

class installlogstash::configlogstash(

        $enablessl = true,
        $logstash_user = 'logstash',
        $logstash_group = 'logstash',
) {

        if($enablessl == true) {
                $ensuressl = present
        } else {
                $ensuressl = absent
        }

        # add jks truststore
        file { '/etc/logstash/truststore.jks' :
                source => "/tmp/elkinstalldir/ssl/truststore.jks",
		owner => $logstash_user,
		group => $logstash_group,
                mode => "0755",
                ensure => $ensuressl,
        }
}

# trigger puppet execution
include installlogstash


