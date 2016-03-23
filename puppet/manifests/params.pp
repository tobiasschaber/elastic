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


}