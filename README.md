# README #

With this project you can automatically setup a complete elasticsearch environment with just a few clicks.
You can either work with vagrant or just use the delivered shell installer scripts and execute them on your nodes.

### Requirements ###

If you want to start up an elasticsearch cluster via vagrant, you need the following tools installed:

* virtualbox (I used 4.3.28)
* vagrant (I used 1.7.4)

### How do I get set up? ###

* Execute the "prepare-ssl.sh" shell script which will create all required ssl certs for you
* perform a "vagrant up" to startup all nodes

### Extended setup ###

If you want to add more nodes or change the names of your nodes, you can adjust them in the /hiera/nodes directory.
Just add a yaml file for every node you want to set up, where the yaml file name must match the hostname of the node.
Simply copy from the existing master- or data-node yaml files and adjust the IP adress inside the file to match the
node.

After changing the node files, reexecute the "prepare-ssl" script which will recreate all ssl artifacts for your nodes.

### Configuration ###

Most configuration is done in the hiere files in the "hiera" directory.