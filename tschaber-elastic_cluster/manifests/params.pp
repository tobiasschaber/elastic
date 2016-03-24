# == Class: elastic_cluster::params
#
#
#
#
class elastic_cluster::params {

    #### Default values for the parameters of the main module class (init.pp)

    # the installation mode (elknode, kibana, logstash, redis, logstash-forwarder)
    $mode = undef

    # should kibana be installed on this node?
    $install_kibana  = false

    # list of all client nodes
    $clientnodes = undef

    # list of all redis nodes
    $redisnodes = undef

    # should redis use ssl?
    $redis_ssl = false

    # the stunnel configuration
    $stunnel_config = undef

    # should collectd be installed on all elk nodes?
    $install_collectd = false

    $collectd_config = {
        collectd_install => false,
    }

    $elk_authentication = {
        enable_authentication => false,
        username              => 'esadmin',
        password              => 'esadmin',
    }


}