# README #

With this project you can automatically setup a complete elasticsearch environment with just a few clicks.
You can either work with vagrant or just use the delivered shell installer scripts and execute them on your nodes.

### Requirements ###

If you want to start up an elasticsearch cluster via vagrant, you need the following packages installed:

* virtualbox (I used 4.3.28)
* vagrant (I used 1.7.4)
    * vagrant "hosts" plugin (installation see chapter below)

### How to quick start? ###

* Execute the "prepare-ssl.sh" shell script which will create all required ssl certs for you
* perform a "vagrant up" to startup all nodes

Attention: "vagrant up" will start up quite a lot of vms. That may exceed your hardware limits! See the "Extended setup" chapter to avoid this.

### Extended setup ###

In the Vagrantfile, there are many vms defined. The default setup contains for example:
- 3 data nodes
- 2 master nodes
- 1 logstash node

You can uncomment some of the nodes. The minimal setup is to run only one data and one master node. Instead of running "vagrant up", you could run "vagrant up elkdata1 elkmaster" to only run the minimum setup.

If you have enough hardware and want to add more nodes, you can just copy and adjust the node blocks in the Vagrantfile. If you add new nodes, you also have to create new hiera files under "hiera/nodes" where the filename must match the hostname of the new nodes. Simply copy from an existing file and adjust the filname and contents of the file! 
You also have to re-run the "prepare-ssl.sh" script and reprovision all already running nodes.

### Configuration ###

Most configuration is done in the hiere files in the "hiera" directory. Here are some of the most important properties which are not coming via external puppet modules:

- installkibana::configkibana::enablehttps: (true/false) enable https for kibana frontend
- elasticsearch::config:shield:transport.ssl: (true/false) enable ssl for encrypted communication between nodes
- elasticsearch::config:shield:http.ssl: (true/false) enable https for elk REST API
- installelknode::configureshield::defaultadminname: the admin user 

### Installation of vagrant hosts plugin ###

The installation of the vagrant hosts plugin will be done by:

vagrant plugin install vagrant-hosts

If you have any problems with nokogiri gem installation, try this before installation:

sudo apt-get install zlib1g-dev


### TODOS ###



