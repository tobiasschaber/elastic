#
#
# this file performs the installation of graylog.
# graylog ui will listen on port 9000?
#
# author: Tobias Schaber (codecentric AG)
#
class installgraylog(

) {



        class {'::mongodb::server':
          port    => 27017,
          verbose => true,
        }

        ->

        class {'graylog2::repo':
          version => '1.1'
        }

        ->


        # root_password_sha2 is encrypted value of 'admin'
        class {'graylog2::server':
                password_secret    => 'veryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecret',
                root_password_sha2 => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
                elasticsearch_cluster_name => 'elkcluster',
                elasticsearch_config_file => '/etc/elasticsearch/es-01/elasticsearch.yml',
                elasticsearch_discovery_zen_ping_multicast_enabled => false,
                elasticsearch_discovery_zen_ping_unicast_hosts => '10.0.3.101:9300',
        }

        ->

        class {'graylog2::web':
          application_secret => 'veryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecret',
        }


}


# trigger puppet execution
include installgraylog

