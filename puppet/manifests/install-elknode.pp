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
	$defaultadminname = "esadmina",
	$defaultadminpass = "esadmina"
) {


	# start the installation with version 2.0.0
	class { 'elasticsearch' :
		ensure => present,
		status => enabled,
		elasticsearch_user => 'elasticsearch',
		elasticsearch_group => 'elasticsearch',
		java_install => true,
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
	class { 'installelknode::adddefaultuser' : 
	}

	
} 

# addition class to add the default admin user to the es configuration
class installelknode::adddefaultuser(
	$defaultadminname = "esadmin",
	$defaultadminpass = "esadmin"
) {
	# create an admin user
	exec { 'shield-create-esadmin':
		user => "root",
		cwd => "/usr/share/elasticsearch/bin/shield",
		command	=> "/usr/share/elasticsearch/bin/shield/esusers useradd $defaultadminname -p $defaultadminpass -r admin",
		unless  => "/usr/share/elasticsearch/bin/shield/esusers list | grep -c $defaultadminname",
		path 	=> ['/usr/sbin/', '/bin/', '/sbin/', '/usr/bin'],
	}
	->
	# workarround: copy esuser files into elasticsearch config directory to be found
	exec { 'copy-esuser-files-into-elk-config-dir':
		user => "root",
		command	=> "cp -r /etc/elasticsearch/shield /etc/elasticsearch/es-01",
		path 	=> ['/usr/sbin/', '/bin/', '/sbin/', '/usr/bin'],
	}

}

# trigger puppet execution
include installelknode

