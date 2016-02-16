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

        class {'graylog2::server':
          password_secret    => 'veryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecret',
          root_password_sha2 => 'd169f5261a42bf88dd088588714a28d8e11a856724b2c10c2f5f22d54dbcb744',
          elasticsearch_cluster_name => 'elkcluster'
        }

        ->

        class {'graylog2::web':
          application_secret => 'veryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecretveryStrongSecret',
        }


}


# trigger puppet execution
include installgraylog

