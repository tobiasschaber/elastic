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
* perform a "vagrant up elkdata1 elkmaster1 elkclient1" to start a "minimal" cluster

Attention: Using "vagrant up" will start up quite a lot of vms. That may exceed your hardware limits! See the "Extended setup" chapter to avoid this.

Kibana is not automatically startet, so use "vagrant ssh elkclient1" to connect to the client node and run "sudo systemctl start kibana" to start kibana.

External links: 
- Kibana: https://localhost:15601
- ELK REST API: https://localhost:19200

### Extended setup ###

In the Vagrantfile, there are many vms defined. The default setup contains for example:
- 3 data nodes
- 2 master nodes
- 2 client nodes
- 1 logstash node

If you have a huge amount of hardware resources, you could run "vagrant up" to start *all* nodes. If not, try one of the following setups:
- vagrant up elkdata1 elkmaster1 elkclient1 (For a minimum setup)
- vagrant up elkdata1 elkmaster1 elkclient1 logstash1 (For a setup with logstash)
- vagrant up elkdata1 elkdata2 elkmaster1 elkclient1 (For a setup with two data nodes)

If you add new nodes, you also have to create new hiera files under "hiera/nodes" where the filename must match the hostname of the new nodes. Simply copy from an existing file and adjust the filname and contents of the file! 
You also have to re-run the "prepare-ssl.sh" script and reprovision all already running nodes.

### Configuration ###

Most configuration is done in the hiere files in the "hiera" directory. Here are some of the most important properties which are not coming via external puppet modules:

- installkibana::configkibana::enablehttps: (true/false) enable https for kibana frontend
- elasticsearch::config:shield:transport.ssl: (true/false) enable ssl for encrypted communication between nodes
- elasticsearch::config:shield:http.ssl: (true/false) enable https for elk REST API
- installelknode::configureshield::defaultadminname: the admin user 

### Installation of Kibana plugins

Kibana plugins can be installed by passing them in via hiera. Have a look at the default hiera/common.yaml where you can find two examples, where the timelion and the marvel plugin are installed automatically.

### Installation of vagrant hosts plugin ###

The installation of the vagrant hosts plugin will be done by:

vagrant plugin install vagrant-hosts

If you have any problems with nokogiri gem installation, try this before installation:

sudo apt-get install zlib1g-dev


### TODOS ###



