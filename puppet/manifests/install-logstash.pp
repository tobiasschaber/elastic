#
#
# this file performs the installation of logstash
#
# author: Tobias Schaber (codecentric AG)
#
class installlogstash(

        # true if redis should be used
        $use_redis = false,

        # true if redis should use stunnel as ssl tunnel provider
        $redis_ssl = false,

        # the role ("default", "shipper" or "indexer") for the logstash instance
        $logstash_role = "default",
) {

        # check role parameter
        if ! ($logstash_role in [ 'indexer', 'default', 'shipper' ]) {
                fail("\"${logstash_role}\" is not valid for logstash_role. valid are: indexer, shipper or default.")
        }

        # roles "indexer" and "shipper" require redis!
        if ($logstash_role in [ 'indexer', 'shipper' ] and $use_redis == false) {
                fail("If use_redis is set to false, you can only use default as logstash_role.")
        }

        $elk_config       = hiera('elasticsearch::config')
        $truststore_pass  = $elk_config['shield']['ssl']['truststore.password']
        $logstash_elkuser = hiera('installelknode::configureshield::defaultadminname', 'logstash')
        $logstash_elkpass = hiera('installelknode::configureshield::defaultadminpass', 'logstash')
        $redis_nodes      = hiera('redis::nodes')

        # start case calculation for redis and stunnel

        # want to use redis?
        if($use_redis == true) {
                $redis_password = hiera('redis::masterauth', 'testccpass')

                # redis with ssl?
                if($redis_ssl == true) {
                        class { 'installlogstash::configstunnel':
                                role => $logstash_role,
                        }

                } else {

                }
        }



        # enable ssl between kibana and elasticsearch?
        $enableelkssl   = $elk_config['shield']['http.ssl']

	# install logstash via the puppet module
	class { 'logstash':
		manage_repo => true,
		ensure => "present",
		status => "running",
	}

        # create the logstash config file
	class { 'installlogstash::prepareconfigfile' :
                role => $logstash_role,

        }
        
        ->

	# perform the configuration steps
	class { 'installlogstash::configlogstash' :
                enablessl => $enableelkssl,
                logstash_user => hiera('logstash::logstash_user'),
                logstash_group => hiera('logstash::logstash_group'),
	}
} 





class installlogstash::configstunnel(

        # the logstash role (shipper, indexer)
        $role = undef,

        # the external local IP
        $bindings = undef,
) {

	# create the stunnel users group
	group { 'create-stunnel-group':
		name => 'stunnel',
		ensure => 'present',
	} ->

	# create the stunnel user
	user { 'create-stunnel-user':
		name => 'stunnel',
		groups => ['stunnel'],
		ensure => 'present',
	} ->

        file { '/etc/stunnel/stunnel_full.pem':
            ensure => 'file',
            owner  => 'root',
            group  => 'root',
            mode   => 700,
            source  => '/tmp/elkinstalldir/ssl/stunnel_full.pem',
        }

        ->

        case $role {
                'shipper': {

                        $shipperdefaults = {
                                cert    => '/etc/stunnel/stunnel_full.pem',
                                client => true,
                        }
                        create_resources("stunnel::tun", $bindings, $shipperdefaults)
                }

                'indexer': {

                        $indexerdefaults = {
                                client => true,
                                cert    => '/etc/stunnel/stunnel_full.pem',
                        }
                        create_resources("stunnel::tun", $bindings, $indexerdefaults)
                }
        }
}




class installlogstash::prepareconfigfile(
	$role = 'default',
) {
        $inst_collectd  = hiera('installelknode::installcollectd')

        # if collect.d should be installed, search hiera for the correct hostname and port
        # and adjust the target index (which will then be "collectd-*" instead of "default-*"
        if($inst_collectd == true) {
                $ownhost = inline_template("<%= scope.lookupvar('::hostname') -%>")
                $collectd_config     = hiera('installelknode::collectd::servers')
                $collectd_port       = $collectd_config[$ownhost]['port']
                $targetindex = 'collectd-%{+YYYY.MM.dd}'
        } else {
                $targetindex = 'default-%{+YYYY.MM.dd}'
        }

	# copy a config file based on a template
	# attention! the path to this file depends on the git clone target directory and may be adjusted!
	logstash::configfile { 'central' :
		content => template("/tmp/elkinstalldir/puppet/templates/logstash-central.conf.erb"),
		order => 10
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


