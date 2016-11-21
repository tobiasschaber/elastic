#
#
# this file performs the installation of logstash
#
# author: Tobias Schaber (codecentric AG)
#
class elastic_cluster::facets::logstash_node(

    # true if redis should use stunnel as ssl tunnel provider
    $redis_ssl = false,

    # the role ("default", "shipper" or "indexer") for the logstash instance
    $logstash_role = 'default',

    # the stunnel configuration
    $stunnel_config = undef,

    # the collectd configuration
    $collectd_config = undef,

    # we need the elk cluster authentication information
    $elk_authentication = undef,
) {

        # check role parameter
        if ! ($logstash_role in [ 'indexer', 'default', 'shipper' ]) {
                fail("\"${logstash_role}\" is not valid for logstash_role. valid are: indexer, shipper or default.")
        }

        # roles "indexer" and "shipper" require redis!
        if ($logstash_role in [ 'indexer', 'shipper' ]) {
                $use_redis = true
        } else {
                $use_redis = false
        }

        $elk_config       = hiera('elasticsearch::config')
        $logstash_elkuser = hiera('installelknode::configureshield::defaultadminname', undef)
        $logstash_elkpass = hiera('installelknode::configureshield::defaultadminpass', undef)
        $redis_nodes      = hiera('elastic_cluster::redisnodes', undef)

        if($elk_config['xpack']) {
                $truststore_pass  = $elk_config['xpack']['ssl']['truststore.password']

                # enable ssl between kibana and elasticsearch?
                $enableelkssl   = $elk_config['xpack']['security']['http.ssl.enabled']

        } else {
                $enableelkssl   = false
        }

        # start case calculation for redis and stunnel

        # want to use redis?
        if($use_redis == true) {
            $redis_password = hiera('redis::masterauth', undef)
            $ownhost = inline_template("<%= scope.lookupvar('::hostname') -%>")

            # redis with ssl?
            if($redis_ssl == true) {
                    class { 'elastic_cluster::facets::logstash_node::configstunnel':
                        role     => $logstash_role,
                        bindings => $stunnel_config['bindings'],
                    }

            } else {

        }
    }



    # install logstash via the puppet module
    class { 'logstash':
        ensure      => 'present',
        manage_repo => true,
        status      => 'running',
    }

        # create the logstash config file
    class { 'elastic_cluster::facets::logstash_node::prepareconfigfile' :
        role               => $logstash_role,
        redis_ssl          => $redis_ssl,
        collectd_config    => $collectd_config,
        elk_authentication => $elk_authentication,

    } ->

    # perform the configuration steps
    class { 'elastic_cluster::facets::logstash_node::configlogstash' :
                enablessl => $enableelkssl,
    }
}





class elastic_cluster::facets::logstash_node::configstunnel(

        # the logstash role (shipper, indexer)
        $role = undef,

        # the external local IP
        $bindings = undef,
) {

    # create the stunnel users group
    group { 'create-stunnel-group':
        ensure => 'present',
        name   => 'stunnel',
    } ->

    # create the stunnel user
    user { 'create-stunnel-user':
        ensure => 'present',
        name   => 'stunnel',
        groups => ['stunnel'],
    } ->

        file { '/etc/stunnel/stunnel_full.pem':
            ensure => 'file',
            owner  => 'root',
            group  => 'root',
            mode   => '0700',
            source => '/tmp/elkinstalldir/ssl/stunnel_full.pem',
        }

        ->

        case $role {
                'shipper': {

                        $shipperdefaults = {
                                cert   => '/etc/stunnel/stunnel_full.pem',
                                client => true,
                        }
                        create_resources('stunnel::tun', $bindings, $shipperdefaults)
                }

                default: {

                        $indexerdefaults = {
                                client => true,
                                cert   => '/etc/stunnel/stunnel_full.pem',
                        }
                        create_resources('stunnel::tun', $bindings, $indexerdefaults)
                }
        }
}




class elastic_cluster::facets::logstash_node::prepareconfigfile(
    $role = 'default',
    $redis_ssl = false,
    $collectd_config = undef,
    $elk_authentication = undef,
) {

    $enable_elk_auth = $elk_authentication['enable_authentication']
    $elk_username = $elk_authentication['username']
    $elk_password = $elk_authentication['password']

    $inst_cld = $collectd_config['collectd_install']

    # if collect.d should be installed, search hiera for the correct hostname and port
    # and adjust the target index (which will then be "collectd-*" instead of "default-*"
    if($inst_cld == true and $role in ['default', 'shipper']) {
        $ownhost = inline_template("<%= scope.lookupvar('::hostname') -%>")
        $collectd_port       = $collectd_config['collectd_servers'][$ownhost]['port']
        $targetindex = 'collectd-%{+YYYY.MM.dd}'
    } else {
        $targetindex = 'default-%{+YYYY.MM.dd}'
    }

    # copy a config file based on a template
    # attention! the path to this file depends on the git clone target directory and may be adjusted!
    logstash::configfile { 'central' :
        content => template('elastic_cluster/logstash-central.conf.erb'),
        order   => 10
    }
}

class elastic_cluster::facets::logstash_node::configlogstash(

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
        ensure => $ensuressl,
        source => '/tmp/elkinstalldir/ssl/truststore.jks',
        owner  => $logstash_user,
        group  => $logstash_group,
        mode   => '0755',
    }
}
