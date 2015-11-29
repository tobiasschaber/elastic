VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

   # elk data server 1
   config.vm.define "elkdata1" do |elkdata1|

	elkdata1.vm.box = "bento/centos-6.7"
	elkdata1.vm.hostname = "elkdata1"
	elkdata1.vm.network "public_network", ip: "10.0.3.111", :bridge => "lxcbr0"
	elkdata1.vm.network "private_network", type: "dhcp"
	elkdata1.vm.network "forwarded_port", guest: 9200, host: 39200
	elkdata1.vm.provision :shell, :path => "install-elkdata.sh"
	elkdata1.vm.provider "virtualbox" do |v|
                 v.memory = 3072 
                 v.cpus = 2
         end
   end

   # elk master server 1
   config.vm.define "elkmaster1" do |elkmaster1|
   
	elkmaster1.vm.box = "bento/centos-6.7"
	elkmaster1.vm.hostname = "elkmaster1"
	elkmaster1.vm.network "public_network", ip: "10.0.3.101", :bridge => "lxcbr0"
	elkmaster1.vm.network "private_network", type: "dhcp"
	elkmaster1.vm.network "forwarded_port", guest: 5601, host: 15601
	elkmaster1.vm.network "forwarded_port", guest: 9200, host: 19200
	elkmaster1.vm.provision :shell, :path => "install-elkmaster.sh"
	elkmaster1.vm.provider "virtualbox" do |v|
                 v.memory = 3072
                 v.cpus = 2
         end
   end

   # elk master server 2
  config.vm.define "elkmaster2" do |elkmaster2|

	elkmaster2.vm.box = "bento/centos-6.7"
	elkmaster2.vm.hostname = "elkmaster2"
	elkmaster2.vm.network "public_network", ip: "10.0.3.102", :bridge => "lxcbr0"
	elkmaster2.vm.network "private_network", type: "dhcp"
	elkmaster2.vm.network "forwarded_port", guest: 5601, host: 25601
	elkmaster2.vm.network "forwarded_port", guest: 9200, host: 29200
	elkmaster2.vm.provision :shell, :path => "install-elkmaster.sh"
	elkmaster2.vm.provider "virtualbox" do |v|
                 v.memory = 3072
                 v.cpus = 2
         end
   end

   # elk data server 2
   config.vm.define "elkdata2" do |elkdata2|

	elkdata2.vm.box = "bento/centos-6.7"
	elkdata2.vm.hostname = "elkdata2"
	elkdata2.vm.network "public_network", ip: "10.0.3.112", :bridge => "lxcbr0"
	elkdata2.vm.network "private_network", type: "dhcp"
	elkdata2.vm.network "forwarded_port", guest: 9200, host: 49200
	elkdata2.vm.provision :shell, :path => "install-elkdata.sh"
	elkdata2.vm.provider "virtualbox" do |v|
                 v.memory = 3072
                 v.cpus = 2
         end
   end

   # elk data server 3
   config.vm.define "elkdata3" do |elkdata3|

        elkdata3.vm.box = "bento/centos-6.7"
        elkdata3.vm.hostname = "elkdata3"
        elkdata3.vm.network "public_network", ip: "10.0.3.113", :bridge => "lxcbr0"
        elkdata3.vm.network "private_network", type: "dhcp"
        elkdata3.vm.network "forwarded_port", guest: 9200, host: 59200
        elkdata3.vm.provision :shell, :path => "install-elkdata.sh"
        elkdata3.vm.provider "virtualbox" do |v|
                 v.memory = 3072
                 v.cpus = 2
         end
   end


#   # logstash server
#   config.vm.define "logstash1" do |logstash1|
#
#	logstash1.vm.box = "bento/centos-6.7"
#	logstash1.vm.hostname = "logstash1"
#	logstash1.vm.network "public_network", ip: "10.0.3.121", :bridge => "lxcbr0"
#	logstash1.vm.network "private_network", type: "dhcp"
#	logstash1.vm.provision :shell, :path => "install-logstash.sh"
#	logstash1.vm.provider "virtualbox" do |v|
#                 v.memory = 3072
#                 v.cpus = 2
#         end
#   end

end



