#
#
# this file performs the installation of an
# elasticsearch master node. it will install the
# node itself including the marvel agent (which
# collects data for marvel) and the licence
# plugin. the node will be named "servername-es-01".
#
# author: Tobias Schaber (codecentric AG)
#
class installelknode(

) {
        # read the complete elk configuration array
        $elk_config     = hiera('elasticsearch::config')

        # if there is a "shield" part in the configuration
        if($elk_config['shield']) {
                $enablessl      = $elk_config['shield']['transport.ssl']
                $enablehttps    = $elk_config['shield']['http.ssl']
        } else {
                # if there is no shield part, disable ssl and https
                $enablessl      = false
                $enablehttps    = false
        }

        $inst_collectd  = hiera('installelknode::collectd::install', undef)


	# start the installation of elasticsearch
	class { 'elasticsearch' :
		ensure => present,
		status => enabled,
	} 

	->

	# add the default admin user
	class { 'installelknode::configureshield' :

	}

	->

        class { 'installelknode::addkeystores' :
                enablessl => $enablessl,
                enablehttps => $enablehttps,
        }


        # install collectd if configured
        if($inst_collectd == true) {

                $collectd_port = hiera('installelknode::collectd::port')
                $collectd_servers = hiera_hash('installelknode::collectd::servers')

                # this is a workaround for a known bug in the collect.d puppet plugin module (https://github.com/voxpupuli/puppet-collectd/issues/162)
                $collectd_version = hiera('installelknode::collectd::version', '5.5.0')
                

                # enterprise packages are required for installation
                package { 'epel-release':
                        ensure => installed,

                } 
                ->
                # install collect.d
                class { '::collectd':
                        package_ensure  => installed,
                        purge           => true,
                        recurse         => true,
                        purge_config    => true,
                        minimum_version => $collectd_version,
                }

                # add the collect.d memory plugin
                class { 'collectd::plugin::memory':
                }

                # add the collect.d cpu plugin
                class { 'collectd::plugin::cpu':
                        reportbystate => true,
                        reportbycpu => true,
                        valuespercentage => true,

                }

                # add the collect.d network plugin and configure it to send to logstash
                class { 'collectd::plugin::network':
                        timetolive    => '70',
                        maxpacketsize => '42',
                        forward       => true,
                        reportstats   => true,
                        servers       => $collectd_servers,
                }
        }
}

# install the required jks trust- and keystores
class installelknode::addkeystores(
        $enablessl = false,
        $enablehttps = false,
        $ownhost = inline_template("<%= scope.lookupvar('::hostname') -%>"),
        $elk_user = hiera('elasticsearch::elasticsearch_user', 'elasticsearch'),
        $elk_group = hiera('elasticsearch::elasticsearch_group', 'elasticsearch')
) {

        # check if truststore is needed
        if($enablehttps == true or $enablessl == true) {
                $ensurejks = present
        } else {
                $ensurejks = absent
        }

	file { '/etc/elasticsearch/es-01/shield' :
		owner => $elk_user,
		group => $elk_group,
                ensure => 'directory',
	} ->

	# add jks keystore
	file { '/etc/elasticsearch/es-01/shield/es01-keystore.jks' :
		source => "/tmp/elkinstalldir/ssl/${ownhost}-keystore.jks",
		owner => $elk_user,
		group => $elk_group,
		mode => "0755",
                ensure => $ensurejks,
	} ->

	# add jks truststore
	file { '/etc/elasticsearch/es-01/shield/es01-truststore.jks' :
		source => "/tmp/elkinstalldir/ssl/truststore.jks",
		owner => $elk_user,
		group => $elk_group,
		mode => "0755",
                ensure => $ensurejks,
	}
}


# addition class to add the default admin user to the es configuration
class installelknode::configureshield(
	$defaultadmin_name = "esadmin",
	$defaultadmin_pass = "esadmin",
        $enable_elk_auth = false,
) {

        if($enable_elk_auth == true) {

	        # create an admin user
	        exec { 'shield-create-esadmin':
		        user => "root",
		        cwd => "/usr/share/elasticsearch/bin/shield",
		        command	=> "/usr/share/elasticsearch/bin/shield/esusers useradd $defaultadmin_name -p $defaultadmin_pass -r admin",
		        unless  => "/usr/share/elasticsearch/bin/shield/esusers list | grep -c $defaultadmin_name",
		        path 	=> ['/usr/sbin/', '/bin/', '/sbin/', '/usr/bin'],
	        }
	        ->
	        # workarround: copy esuser files into elasticsearch config directory to be found
	        exec { 'copy-esuser-files-into-elk-config-dir':
		        user => hiera('elasticsearch::elasticsearch_user', 'elasticsearch'),
		        command	=> "cp -r /etc/elasticsearch/shield /etc/elasticsearch/es-01",
		        path 	=> ['/usr/sbin/', '/bin/', '/sbin/', '/usr/bin'],
	        }
        }
}

# trigger puppet execution
include installelknode

