require 'spec_helper'

describe 'elastic_cluster' do

    let(:title) { 'kibananode' }

    let(:facts) {
        {
            :ipaddress => '10.0.2.15',
            :ipaddress_eth0 => '10.0.2.15',
            :ipaddress_eth1 => '10.0.3.131',
            :kernel => 'Linux',
            :kernelmajversion => '3.13',
            :kernelversion => '3.13.0',
            :lsbdistcodename => 'trusty',
            :lsbdistdescription => 'Ubuntu 14.04.4 LTS',
            :lsbdistid => 'Ubuntu',
            :lsbdistrelease => '14.04',
            :lsbmajdistrelease => '14',
            :operatingsystem => 'Ubuntu',
            :operatingsystemrelease => '14.04',
            :osfamily => 'Debian',
            :hostname => 'elkclient1',
            :hardwaremodel => 'x86_64',
        }
    }

    it { should create_class('elastic_cluster::facets::kibana_node')}


end