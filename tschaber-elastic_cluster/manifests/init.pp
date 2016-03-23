# == Class: elastic_cluster
#
# This class can be used to install a complete elasticsearch cluster with different
# options. You can use this class to install elasticsearch, logstash, kibana, redis and more.
#
# === Parameters
#
# [*mode*]
#   the mode to use for this node (e.g. elknode, logstash, redis, logstashforwarder)
#
#

# === Authors
#
# Tobias Schaber <tobias.schaber@codecentric.de>
#
class elastic_cluster(
    $mode           = $elastic_cluster::params::mode,
    $install_kibana = $elastic_cluster::params::install_kibana,
    $clientnodes    = $elastic_cluster::params::clientnodes,
    $redisnodes     = $elastic_cluster::params::redisnodes,

) inherits elastic_cluster::params {


    #### validate params

    if ! ($mode in ["elknode", "logstash", "redis", "logstashforwarder"]) {
        fail("\"$mode\" is not a valid [mode] parameter.")
    }


    #### include required classes

    case $mode {
        'logstash': {
            class { 'elastic_cluster::facets::logstash_node': }
        }

        'elknode': {
            class { 'elastic_cluster::facets::elastic_node': }
        }

        'redis': {
            class { 'elastic_cluster::facets::redis_node': }
        }

        'logstashforwarder': {
            class { 'elastic_cluster::facets::logstash_forwarder_node': }
        }
    }

    # install kibana on this node?
    if($install_kibana == true) {
        class { 'elastic_cluster::facets::kibana_node': }
    }


}

