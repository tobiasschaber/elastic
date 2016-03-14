VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

#   config.ssh.insert_key = false


   # allow hostname resolution
   config.vm.provision :hosts do |prov|
	prov.add_host '10.0.3.101', ['elkmaster1']
	prov.add_host '10.0.3.102', ['elkmaster2']
	prov.add_host '10.0.3.111', ['elkdata1']
        prov.add_host '10.0.3.112', ['elkdata2']
        prov.add_host '10.0.3.113', ['elkdata3']
        prov.add_host '10.0.3.121', ['logstash1']
        prov.add_host '10.0.3.122', ['logstashindexer1']
        prov.add_host '10.0.3.123', ['logstashshipper1']
        prov.add_host '10.0.3.124', ['logstashindexer2']
        prov.add_host '10.0.3.125', ['logstashshipper2']
        prov.add_host '10.0.3.131', ['elkclient1']
        prov.add_host '10.0.3.132', ['elkclient2']
        prov.add_host '10.0.3.141', ['redis1']
        prov.add_host '10.0.3.142', ['redis2']
   end


   # snapshot shared NFS folder
   config.vm.synced_folder ".", "/vagrant", type: "nfs"


#   config.vm.synced_folder ".", "/snapshot", type: "nfs"


   # use cachier plugin if existing
   config.vm.box = "bento/centos-7.1"
   if Vagrant.has_plugin?("vagrant-cachier")
   	config.cache.scope = :box
   end


   # elk data server 1
   config.vm.define "elkdata1" do |elkdata1|

	elkdata1.vm.box = "bento/centos-7.1"
	elkdata1.vm.hostname = "elkdata1"
	elkdata1.vm.network "public_network", ip: "10.0.3.111", :bridge => "lxcbr0"
	elkdata1.vm.network "private_network", type: "dhcp"
	elkdata1.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkdata1.vm.provision :shell, :path => "install-elknode.sh"
	elkdata1.vm.provider "virtualbox" do |v|
                 v.memory = 768 
                 v.cpus = 2
         end
   end

   # elk master server 1
   config.vm.define "elkmaster1" do |elkmaster1|
   
	elkmaster1.vm.box = "bento/centos-7.1"
	elkmaster1.vm.hostname = "elkmaster1"
	elkmaster1.vm.network "public_network", ip: "10.0.3.101", :bridge => "lxcbr0"
	elkmaster1.vm.network "private_network", type: "dhcp"
	elkmaster1.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkmaster1.vm.provision :shell, :path => "install-elknode.sh"
	elkmaster1.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
   end

   # elk master server 2
  config.vm.define "elkmaster2" do |elkmaster2|

	elkmaster2.vm.box = "bento/centos-7.1"
	elkmaster2.vm.hostname = "elkmaster2"
	elkmaster2.vm.network "public_network", ip: "10.0.3.102", :bridge => "lxcbr0"
	elkmaster2.vm.network "private_network", type: "dhcp"
	elkmaster2.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkmaster2.vm.provision :shell, :path => "install-elknode.sh"
	elkmaster2.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
   end

   # elk data server 2
   config.vm.define "elkdata2" do |elkdata2|

	elkdata2.vm.box = "bento/centos-7.1"
	elkdata2.vm.hostname = "elkdata2"
	elkdata2.vm.network "public_network", ip: "10.0.3.112", :bridge => "lxcbr0"
	elkdata2.vm.network "private_network", type: "dhcp"
	elkdata2.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkdata2.vm.provision :shell, :path => "install-elknode.sh"
	elkdata2.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
   end

   # elk data server 3
   config.vm.define "elkdata3" do |elkdata3|

        elkdata3.vm.box = "bento/centos-7.1"
        elkdata3.vm.hostname = "elkdata3"
        elkdata3.vm.network "public_network", ip: "10.0.3.113", :bridge => "lxcbr0"
        elkdata3.vm.network "private_network", type: "dhcp"
	elkdata3.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkdata3.vm.provision :shell, :path => "install-elknode.sh"
        elkdata3.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
   end

   # elk client 1
   config.vm.define "elkclient1" do |elkclient1|

	elkclient1.vm.box = "bento/centos-7.1"
	elkclient1.vm.hostname = "elkclient1"
	elkclient1.vm.network "public_network", ip: "10.0.3.131", :bridge => "lxcbr0"
	elkclient1.vm.network "private_network", type: "dhcp"
	elkclient1.vm.network "forwarded_port", guest: 5601, host: 15601
	elkclient1.vm.network "forwarded_port", guest: 9200, host: 19200
	elkclient1.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkclient1.vm.provision :shell, :path => "install-elknode.sh"
	elkclient1.vm.provision :shell, :path => "install-kibana.sh"
	elkclient1.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

   # elk client 2
   config.vm.define "elkclient2" do |elkclient2|

	elkclient2.vm.box = "bento/centos-7.1"
	elkclient2.vm.hostname = "elkclient2"
	elkclient2.vm.network "public_network", ip: "10.0.3.132", :bridge => "lxcbr0"
	elkclient2.vm.network "private_network", type: "dhcp"
	elkclient2.vm.network "forwarded_port", guest: 5601, host: 25601
	elkclient2.vm.network "forwarded_port", guest: 9200, host: 29200
	elkclient2.vm.provision :shell, :path => "installation/prepare-install.sh"
	elkclient2.vm.provision :shell, :path => "install-elknode.sh"
	elkclient2.vm.provision :shell, :path => "install-kibana.sh"
	elkclient2.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

   # logstash shipper server
   config.vm.define "logstash1" do |logstash1|

	logstash1.vm.box = "bento/centos-7.1"
	logstash1.vm.hostname = "logstash1"
	logstash1.vm.network "public_network", ip: "10.0.3.121", :bridge => "lxcbr0"
	logstash1.vm.network "private_network", type: "dhcp"
	logstash1.vm.provision :shell, :path => "installation/prepare-install.sh"
	logstash1.vm.provision :shell, :path => "install-logstash.sh"
	logstash1.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end



   # logstash indexing server
   config.vm.define "logstashindexer1" do |logstashindexer1|

	logstashindexer1.vm.box = "bento/centos-7.1"
	logstashindexer1.vm.hostname = "logstashindexer1"
	logstashindexer1.vm.network "public_network", ip: "10.0.3.122", :bridge => "lxcbr0"
	logstashindexer1.vm.network "private_network", type: "dhcp"
	logstashindexer1.vm.provision :shell, :path => "installation/prepare-install.sh"
	logstashindexer1.vm.provision :shell, :path => "install-logstash.sh"
	logstashindexer1.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

   # logstash indexing server
   config.vm.define "logstashindexer2" do |logstashindexer2|

	logstashindexer2.vm.box = "bento/centos-7.1"
	logstashindexer2.vm.hostname = "logstashindexer2"
	logstashindexer2.vm.network "public_network", ip: "10.0.3.124", :bridge => "lxcbr0"
	logstashindexer2.vm.network "private_network", type: "dhcp"
	logstashindexer2.vm.provision :shell, :path => "installation/prepare-install.sh"
	logstashindexer2.vm.provision :shell, :path => "install-logstash.sh"
	logstashindexer2.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end


   # logstash shipper server
   config.vm.define "logstashshipper1" do |logstashshipper1|

	logstashshipper1.vm.box = "bento/centos-7.1"
	logstashshipper1.vm.hostname = "logstashshipper1"
	logstashshipper1.vm.network "public_network", ip: "10.0.3.123", :bridge => "lxcbr0"
	logstashshipper1.vm.network "private_network", type: "dhcp"
	logstashshipper1.vm.provision :shell, :path => "installation/prepare-install.sh"
	logstashshipper1.vm.provision :shell, :path => "install-logstash.sh"
	logstashshipper1.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

   # logstash shipper server
   config.vm.define "logstashshipper2" do |logstashshipper2|

	logstashshipper2.vm.box = "bento/centos-7.1"
	logstashshipper2.vm.hostname = "logstashshipper2"
	logstashshipper2.vm.network "public_network", ip: "10.0.3.125", :bridge => "lxcbr0"
	logstashshipper2.vm.network "private_network", type: "dhcp"
	logstashshipper2.vm.provision :shell, :path => "installation/prepare-install.sh"
	logstashshipper2.vm.provision :shell, :path => "install-logstash.sh"
	logstashshipper2.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

   # redis 1
   config.vm.define "redis1" do |redis1|

	redis1.vm.box = "bento/centos-7.1"
	redis1.vm.hostname = "redis1"
	redis1.vm.network "public_network", ip: "10.0.3.141", :bridge => "lxcbr0"
	redis1.vm.network "private_network", type: "dhcp"
	redis1.vm.provision :shell, :path => "installation/prepare-install.sh"
	redis1.vm.provision :shell, :path => "install-redis.sh"
	redis1.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

   # redis 2
   config.vm.define "redis2" do |redis2|

	redis2.vm.box = "bento/centos-7.1"
	redis2.vm.hostname = "redis2"
	redis2.vm.network "public_network", ip: "10.0.3.142", :bridge => "lxcbr0"
	redis2.vm.network "private_network", type: "dhcp"
	redis2.vm.provision :shell, :path => "installation/prepare-install.sh"
	redis2.vm.provision :shell, :path => "install-redis.sh"
	redis2.vm.provider "virtualbox" do |v|
                 v.memory = 768
                 v.cpus = 2
         end
    end

end



