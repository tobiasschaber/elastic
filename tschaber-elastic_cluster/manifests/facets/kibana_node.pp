#
#
# this file performs the installation of kibana.
#
# author: Tobias Schaber (codecentric AG)
#
class elastic_cluster::facets::kibana_node(

    # get the url to the kibana installer archive
    $kibanaurl = undef,

    # the kibana system user
    $kibana_user =  'kibana',

    # the kibana system user group
    $kibana_group = 'kibana',

    # enable https between kibana and client browser
    $enablehttps = false,

    # the plugin list
    $plugins = undef,

    # ELK authentication configuration
    $elk_authentication = undef,
){

    # read the ELK configuration from hiera
    $elk_config = hiera('elasticsearch::config')

    # enable ssl between kibana and elasticsearch?
    if($elk_config['shield']) {
        $enableelkssl   = $elk_config['shield']['http.ssl']
    } else {
        $enableelkssl = false
    }

    # if the plugin list exists
    if $plugins {
        # pass the plugin list hash to the installer function
        create_resources('elastic_cluster::facets::kibana_node::installplugins', $plugins)
    }

    # create the kibana users group
    group { 'create-kibana-group':
        ensure => 'present',
        name   => $kibana_group,
    }

    # create the kibana user
    user { 'create-kibana-user':
        ensure => 'present',
        name   => $kibana_user,
        groups => [$kibana_group],
    } ->

        # download the kibana installer via a wget and save it unter /tmp/...
    wget::fetch { 'download_kibana4':
        source      => $kibanaurl,
        destination => '/tmp/kibana.tar.gz',
        timeout     => 0,
        verbose     => false,
        execuser    => $kibana_user,
        cache_dir   => '/var/cache',
    } ->

        # ensure that the kibana4 installation directory exists
    file { '/opt/kibana4':
        ensure => 'directory',
        owner  => $kibana_user,
        group  => $kibana_group,
    } ->

        # extract the kibana4 archive into the target installation directory
    exec { 'untar-kibana4':
        command => 'tar -xvf /tmp/kibana.tar.gz -C /opt/kibana4 --strip-components=1',
        path    => '/bin',
        user    => $kibana_user,
    } ->

        # ensure that a kibana configuration was created and exists now
    file { '/opt/kibana4/config/kibana.yml':
        ensure => present,
    } ->

        # ensure that the kibana ssl directory exists and has correct rights
    file { '/opt/kibana4/ssl' :
        ensure => 'directory',
        owner  => $kibana_user,
        group  => $kibana_group,
        mode   => '0600',
    } ->


        # create the kibana init script. copy it from the checked out git repository
    file { '/etc/init.d/kibana' :
        source => 'puppet:///modules/elastic_cluster/kibanainit',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    } ->

        # create the kibana default script. copy it from the checked out git repository
    file { '/etc/default/kibana' :
        content => template('elastic_cluster/kibanadefault.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
    } ->

        # make sure that the kibana service is stopped because it should be started at the end
    service { 'start-kibana' :
        ensure => 'stopped',
        name   => 'kibana',
    } ->

        # perform the configuration steps
    class { 'elastic_cluster::facets::kibana_node::configkibana' :
        enablehttps     => $enablehttps,
        enablessl       => $enableelkssl,
        elk_enable_auth => $elk_authentication['enable_authentication'],
        kibanaelkuser   => $elk_authentication['username'],
        kibanaelkpass   => $elk_authentication['password'],
    }

#    if($operatingsystem in ['RedHat', 'CentOS']) {
#        # enterprise packages are required for installation
#        package { 'epel-release':
#            ensure => installed,
#        }
    #}
}

class elastic_cluster::facets::kibana_node::configkibana(

    $sslsourcescert   = '/tmp/elkinstalldir/ssl/kibana.crt',
    $sslsourceskey    = '/tmp/elkinstalldir/ssl/kibana.key',
    $sslcacert        = '/tmp/elkinstalldir/ssl/root-ca.crt',
    $kibanaelkuser    = 'esadmin',
    $kibanaelkpass    = 'esadmin',
    $enablehttps      = false,
    $enablessl        = false,
    $elk_enable_auth  = false,
    $kibana_user      = 'kibana',
    $kibana_group     = 'kibana',
) {

    if($enablehttps == true) {
        $ensurehttps = present
        $server_sslcert_line    = 'server.ssl.cert: /opt/kibana4/ssl/elkcluster.crt'
        $server_sslkey_line     = 'server.ssl.key: /opt/kibana4/ssl/elkcluster.key'
    } else {
        $ensurehttps = absent
        $server_sslcert_line    = '#server.ssl.cert: '
        $server_sslkey_line     = '#server.ssl.key: '
    }

    if($enablessl == true) {
        $ensuressl = present
        $urlprotocol = 'https'
        $elk_sslca_line = 'elasticsearch.ssl.ca: /opt/kibana4/ssl/root-ca.crt'
    } else {
        $ensuressl = absent
        $urlprotocol = 'http'
        $elk_sslca_line = '#elasticsearch.ssl.ca: '
    }

    $ownhost = inline_template("<%= scope.lookupvar('::hostname') -%>")

    # copy the https ssl key into kibana
    file { '/opt/kibana4/ssl/elkcluster.key' :
        ensure => $ensurehttps,
        source => $sslsourceskey,
        owner  => $kibana_user,
        group  => $kibana_group,
        mode   => '0600',
    } ->

        # copy the ssl root-ca into kibana
    file { '/opt/kibana4/ssl/root-ca.crt' :
        ensure => $ensuressl,
        source => $sslcacert,
        owner  => $kibana_user,
        group  => $kibana_group,
        mode   => '0755',
    } ->

        # copy the https ssl cert into kibana
    file { '/opt/kibana4/ssl/elkcluster.crt' :
        ensure => $ensurehttps,
        source => $sslsourcescert,
        owner  => $kibana_user,
        group  => $kibana_group,
    } ->

        # adjust the kibana configuration by setting the correct elasticsearch url.
        # kibana will connect to elasticsearch on its own localhost
    file_line { 'Add es to config.yml':
        path  => '/opt/kibana4/config/kibana.yml',
        line  => "elasticsearch.url: \"${urlprotocol}://${ownhost}:9200\"",
        match => 'elasticsearch.url:*',
    } ->

        # adjust the kibana configuration by setting the ssl cert path
        # to enable https
    file_line { 'Add https crt to server':
        path  => '/opt/kibana4/config/kibana.yml',
        line  => $server_sslcert_line,
        match => '#?server.ssl.cert:*',
    } ->

        # adjust the kibana configuration by setting the ssl key path
        # to enable https
    file_line { 'Add https key to server':
        path  => '/opt/kibana4/config/kibana.yml',
        line  => $server_sslkey_line,
        match => '#?server.ssl.key:*',
    } ->

        # adjust the kibana configuration by setting the ssl cert path
        # to enable ssl between kibana and elk
    file_line { 'Add root ca for ssl to server':
        path  => '/opt/kibana4/config/kibana.yml',
        line  => $elk_sslca_line,
        match => '#?elasticsearch.ssl.ca:*',
    }

    if($elk_enable_auth == true) {
        # add elasticsearch user to config
        file_line { 'Add elk user to config':
            path  => '/opt/kibana4/config/kibana.yml',
            line  => "elasticsearch.username: ${kibanaelkuser}",
            match => '#?elasticsearch.username:*',
        } ->

            # add elasticsearch pass to config
        file_line { 'Add elk pass to config':
            path  => '/opt/kibana4/config/kibana.yml',
            line  => "elasticsearch.password: ${kibanaelkpass}",
            match => '#?elasticsearch.password:*',
        }
    }
}

# define the installation routine which installs an kibana plugin
# $source parameter is currently not read.
define elastic_cluster::facets::kibana_node::installplugins($source) {

    # calculate the "short form" of the plugin name,
    # for example "marvel" in "elasticsearch/marvel/latest".
    $shortarray = split($name, '/')
    $shortname = $shortarray[1]

    # itearte over all kibana plugins and install them
    exec { $name:
        path    => ['/usr/local/bin', '/bin', '/usr/bin', '/usr/local/sbin'],
        command => "/opt/kibana4/bin/kibana plugin --install ${name}",
        creates => "/opt/kibana4/installedPlugins/${shortname}",
        user    => 'root',
        cwd     => '/opt/kibana4/',
        require => Class['elastic_cluster::facets::kibana_node::configkibana']
    }
}


