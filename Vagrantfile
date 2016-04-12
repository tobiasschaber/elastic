VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # allow hostname resolution
    config.vm.provision :hosts do |prov|
        prov.add_host '10.0.3.101', ['elkmaster1']
        prov.add_host '10.0.3.111', ['elkdata1']
        prov.add_host '10.0.3.121', ['logstash1']
        prov.add_host '10.0.3.131', ['elkclient1']
    end

    # configure the operating system for all nodes
    #config.vm.box = "bento/centos-6.7"
    config.vm.box = "bento/centos-7.1"
    #config.vm.box = "ubuntu/trusty64"


    # snapshot shared NFS folder
   config.vm.synced_folder ".", "/vagrant", type: "nfs"

    # use cachier plugin if existing
    if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
    end

    # -------------------------------------------------------------------
    # node configuration
    # -------------------------------------------------------------------

    # elk data server 1
    config.vm.define "elkdata1" do |elkdata1|

        elkdata1.vm.hostname = "elkdata1"
        elkdata1.vm.network "public_network", ip: "10.0.3.111", :bridge => "lxcbr0"
        elkdata1.vm.network "private_network", type: "dhcp"
        elkdata1.vm.provision :shell, :path => "installation/prepare-install.sh"
        elkdata1.vm.provision :shell, :path => "install-elknode.sh"
        elkdata1.vm.provider "virtualbox" do |v|
            v.memory = 1200
            v.cpus = 2
        end
    end

    # elk master server 1
    config.vm.define "elkmaster1" do |elkmaster1|

        elkmaster1.vm.hostname = "elkmaster1"
        elkmaster1.vm.network "public_network", ip: "10.0.3.101", :bridge => "lxcbr0"
        elkmaster1.vm.network "private_network", type: "dhcp"
        elkmaster1.vm.provision :shell, :path => "installation/prepare-install.sh"
        elkmaster1.vm.provision :shell, :path => "install-elknode.sh"
        elkmaster1.vm.provision :shell, :path => "start-kibana.sh"
        elkmaster1.vm.provider "virtualbox" do |v|
             v.memory = 1200
             v.cpus = 2
        end
    end

       # elk client 1
       config.vm.define "elkclient1" do |elkclient1|

        elkclient1.vm.hostname = "elkclient1"
        elkclient1.vm.network "public_network", ip: "10.0.3.131", :bridge => "lxcbr0"
        elkclient1.vm.network "private_network", type: "dhcp"
        elkclient1.vm.network "forwarded_port", guest: 5601, host: 15601
        elkclient1.vm.network "forwarded_port", guest: 9200, host: 19200
        elkclient1.vm.provision :shell, :path => "installation/prepare-install.sh"
        elkclient1.vm.provision :shell, :path => "install-elknode.sh"
        elkclient1.vm.provider "virtualbox" do |v|
            v.memory = 1024
            v.cpus = 2
        end
    end



       # logstash shipper server
       config.vm.define "logstash1" do |logstash1|

        logstash1.vm.hostname = "logstash1"
        logstash1.vm.network "public_network", ip: "10.0.3.121", :bridge => "lxcbr0"
        logstash1.vm.network "private_network", type: "dhcp"
        logstash1.vm.provision :shell, :path => "installation/prepare-install.sh"
        logstash1.vm.provision :shell, :path => "install-logstash.sh"
        logstash1.vm.provision :shell, :path => "install-apps.sh"
        logstash1.vm.provider "virtualbox" do |v|
            v.memory = 768
            v.cpus = 2
        end
    end
end
