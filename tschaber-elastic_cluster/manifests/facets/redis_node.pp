#
#
# this file performs the installation of a
# redis node.
#
# author: Tobias Schaber (codecentric AG)
#
class elastic_cluster::facets::redis_node(

    # true if redis should use stunnel as ssl tunnel provider
    $redis_ssl = false,

    # the stunnel configuration
    $stunnel_config = undef,

) {
    $ownhost = inline_template("<%= scope.lookupvar('::hostname') -%>")
    $bindings = $stunnel_config['bindings']

    if($redis_ssl == true) {

        # create the stunnel users group
        group { 'create-stunnel-group':
            name   => 'stunnel',
            ensure => 'present',
        } ->

            # create the stunnel user
        user { 'create-stunnel-user':
            name   => 'stunnel',
            groups => ['stunnel'],
            ensure => 'present',
        } ->

        file { '/etc/stunnel/stunnel_full.pem':
            ensure  => 'file',
            owner   => 'root',
            group   => 'root',
            mode    => 700,
            source  => '/tmp/elkinstalldir/ssl/stunnel_full.pem',
            before  => Class['stunnel'],
        } ->

        stunnel::tun { 'redis-server':
            accept  =>  $bindings[$ownhost]['accept'],
            connect =>  $bindings[$ownhost]['connect'],
            client  =>  false,
            cert    =>  '/etc/stunnel/stunnel_full.pem',
        }

        # with stunnel, listen on 127.0.0.1
        $redisbind = $bindings[$ownhost]['accept']

    } else {
        # without stunnel, listen on public IP
        $redisbind = $bindings[$ownhost]['connect']
    }

    $redisbindip = inline_template("<%= redisbind.split(':')[0] -%>")


    # start the installation of redis
    class { 'redis' :
        manage_repo => true,
        bind        => $redisbindip
    }
}

