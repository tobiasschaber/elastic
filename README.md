# README #

With this project you can automatically setup a complete elasticsearch environment with just a few clicks.
You can either work with vagrant or just use the delivered shell installer scripts and execute them on your nodes.

## Prequisites ##

If you want to start up an elasticsearch cluster via vagrant, you need the following packages installed:

* virtualization:
    * virtualbox (I used 4.3.28)
    * vagrant (I used 1.7.4)
    * vagrant "hosts" plugin (installation see chapter below)
* ssl cert creation:
    * java keytool
    * openssl



## How to quick start? ##

### Start the cluster ###

the quickest way to start an ELK cluster is to run the default setup

* execute the `./prepare-ssl.sh` shell script (which will create all required ssl certs for you)
* execute `vagrant up elkdata1 elkmaster1 elkclient1` to start a minimum cluster
* execute `vagrant ssh elkclient1` to connect to the client node and run `sudo systemctl start kibana` to start kibana
* execute `vagrant up logstash1` if you want to use logstash. It will connect automatically

This will start a fully connected and working cluster with three nodes (master, client, and data node) with the following setup:
- no ssl
- no https
- no authentication
- no plugins
- no redis

it will run collectd on all ELK nodes, so that you automatically will have some data to play with (requires logstash1 node!)


### General info after startup ###

External URLs: 
- Kibana: http(s)://10.0.3.131:5601 OR http(s)://localhost:15601
- ELK REST API: http(s)://10.0.3.131:9200 OR http(s)://localhost:19200





## Hiera configuration ##

There are two places where you can configure the cluster via hiera:
- /hiera/common.yaml (global configuration)
- /hiera/nodes/<node>.yaml (node specific configuration)


### Global configuration (common.yaml) ###

TODO

### Node specific configuration (nodes/<node>.yaml) ###

For every node created, there must be a specific configuration yaml file in the hiera/nodes directory. 
The file name must match the hostname of the node to be applied correctly.

Have a look at the following example configurations: There is a configuration for each type of node.


#### Elasticsearch client node ####

If you want to configure an ELK client node, use this node configuration:

    ---
    elasticsearch::instances:
      es-01:
        config:
          network.bind_host: 0.0.0.0
          network.publish_host: 10.0.3.131
          node.data: false
          node.master: false

The combination of `node.data` and `node.master` will determine the role of the node in the cluster.
Setting both to `false` will bring up a client node.
Set `publish_host` to the hosts IP and `bind_host` to the listening interface IP.

#### Elasticsearch data node ####

If you want to configure an ELK data node, use this node configuration:

    ---
    elasticsearch::instances:
      es-01:
        config:
          network.bind_host: 0.0.0.0
          network.publish_host: 10.0.3.111
          node.data: true
          node.master: false
          http.enabled: false

The combination of `node.data` and `node.master` will determine the role of the node in the cluster.
Setting `node.data: true` and `node.master: false` will bring up a data node. Set `http.enabled: false`
if you have dedicated client nodes.
Set `publish_host` to the hosts IP and `bind_host` to the listening interface IP.

#### Elasticsearch master node ####

If you want to configure an ELK master node, use this node configuration:

    ---
    elasticsearch::instances:
      es-01:
        config:
          network.bind_host: 0.0.0.0
          network.publish_host: 10.0.3.101
          node.data: false
          node.master: true
          http.enabled: false

The combination of `node.data` and `node.master` will determine the role of the node in the cluster.
Setting `node.data: false` and `node.master: true` will bring up a master node. Set `http.enabled: false`
if you have dedicated client nodes.
Set `publish_host` to the hosts IP and `bind_host` to the listening interface IP.


#### Logstash node (without redis) ####

If you want to configure an ELK logstash node without redis setup, use this node configuration:

    ---
    installlogstash::logstash_role: default
    installlogstash::redis_ssl: false

Setting `installlogstash::logstash_role: default` will bring up a logstash node without redis, which already contains
a very simple basic logstash configuration (write something into /tmp/input, send it into /tmp/output and to elasticsearch).


#### Logstash node (with redis, shipper mode) ####

If you want to configure an ELK logstash node with redis between, use this configuration for the shippers:

    ---
    installlogstash::logstash_role: shipper
    installlogstash::redis_ssl: true
    installlogstash::configstunnel::bindings:
      redis1:
        accept: 127.0.0.1:13371
        connect: 10.0.3.141:6379
      redis2:
        accept: 127.0.0.1:13372
        connect: 10.0.3.142:6379

#### Logstash node (with redis, indexer mode) ####

If you want to configure an ELK logstash node with redis between, use this configuration for the indexers:

    ---
    installlogstash::logstash_role: indexer
    installlogstash::use_redis: true
    installlogstash::redis_ssl: true
    installlogstash::configstunnel::bindings:
      redis1:
        accept: 127.0.0.1:13371
        connect: 10.0.3.141:6379
      redis2:
        accept: 127.0.0.1:13372
        connect: 10.0.3.142:6379

#### Redis Node ####

If you want to configure a redis node, use this node configuration:

    ---
    installredis::redis_ssl: true
    installredis::bindings:
      server:
        accept: 10.0.3.141:6379
        connect: 127.0.0.1:6379


















### Extended setup ###

In the Vagrantfile, there are many vms defined. The default setup contains for example:
- 3 data nodes
- 2 master nodes
- 2 client nodes
- 1 logstash node
- 1 redis master
- 1 redis slave

If you have a huge amount of hardware resources, you could run "vagrant up" to start *all* nodes. If not, try one of the following setups:
- vagrant up elkdata1 elkmaster1 elkclient1 (For a minimum ELK cluster setup)
- vagrant up elkdata1 elkdata2 elkmaster1 elkclient1 (For a setup with two data nodes)
- execute vagrant up elkdata1 elkmaster1 elkclient1 logstash1
- vagrant up elkdata1 elkmaster1 elkclient1 redis1 logstashshipper1 logstashindexer1 (For a full logstash/redis/elk pipeline)

Please note: If you start up less nodes than mentioned in your redis configuration (e.g. if you do not start up all nodes which are listed in the common.yaml -> redis::nodes),
you might get some errors because some hosts are not reachable.

If you add new nodes on your own, you also have to create new hiera files under "hiera/nodes" where the filename must match the hostname of the new nodes. Simply copy from an existing file and adjust the filname and contents of the file! You also have to re-run the "prepare-ssl.sh" script and reprovision all already running nodes!

### Configuration ###

Most configuration is done in the hiere files in the "hiera" directory. Here are some of the most important properties which are not coming via external puppet modules:

- installkibana::configkibana::enablehttps: (true/false) enable https for kibana frontend
- elasticsearch::config:shield:transport.ssl: (true/false) enable ssl for encrypted communication between nodes
- elasticsearch::config:shield:http.ssl: (true/false) enable https for elk REST API
- installelknode::configureshield::defaultadminname: the admin user 

### Installation of Kibana plugins ###

Kibana plugins can be installed by passing them in via hiera. Have a look at the default hiera/common.yaml where you can find two examples, where the timelion and the marvel plugin are installed automatically.

### Installation of vagrant hosts plugin ###

The installation of the vagrant hosts plugin will be done by:

vagrant plugin install vagrant-hosts

If you have any problems with nokogiri gem installation, try this before installation:

sudo apt-get install zlib1g-dev


### Redis and Logstash scenarios ###

There are two redis nodes (redis1 and redis2) which start up as independent nodes. They do NOT build
a cluster or are configured with a failover mechanism.

If you want to use redis, you can set up two logstash instances: one shipper and one indexer. Depending on their
configuration they will use redis as input and elasticsearch as output (indexer) or file input and redis output (shipper).




