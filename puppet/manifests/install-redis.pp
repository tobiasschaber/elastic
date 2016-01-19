#
#
# this file performs the installation of a
# redis node.
#
# author: Tobias Schaber (codecentric AG)
#
class installredis(

        $redis_ssl = false,
        $bindings = undef,

) {
        if($redis_ssl == true) {

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

                $redisdefaults = {
                        client => false,
                        cert    => '/etc/stunnel/stunnel_full.pem',
                }
                create_resources("stunnel::tun", $bindings, $redisdefaults)
        }


	# start the installation of redis
	class { 'redis' :
                manage_repo => true,
	}
}



# trigger puppet execution
include installredis

