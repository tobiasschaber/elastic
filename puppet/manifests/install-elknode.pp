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
        $elk_config     = hiera('elasticsearch::config')
        $enablessl      = $elk_config['shield']['transport.ssl']
        $enablehttps    = $elk_config['shield']['http.ssl']


	# start the installation of elasticsearch
	class { 'elasticsearch' :
		ensure => present,
		status => enabled,
	} 
	->
	
	elasticsearch::plugin{'elasticsearch/license/latest':
		instances  => 'es-01'
	} 
	->
	elasticsearch::plugin{'marvel-agent':
		instances  => 'es-01'
	}
	->
	elasticsearch::plugin{'elasticsearch/watcher/latest':
		instances  => 'es-01'
	}
	->
	elasticsearch::plugin{'elasticsearch/shield/latest':
		instances  => 'es-01'
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
	$defaultadmin_pass = "esadmin"
) {

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

# trigger puppet execution
include installelknode

