#!/bin/bash





# ------------------------------------------------------------------------ CHECK IF VAGRANT PLUGIN IS INSTALLED --- #
# signature:
# $1: required plugin
function check_vagrant_plugin(){

        # check if the plugin is in the plugin list
        vagrant plugin list | grep $1 > /dev/null
        
        if [ $? != 0 ]
                then
                        echo "you have to install the vagrant plugin \"$1\" before starting the cluster."
                        exit

        fi

}


# ------------------------------------------------------------------------ CHECK IF ALL REQUIRED SOFTWWARE IS AVAILABLE --- #
# signature:
# $1: required command
# $2: package info (which package do I need to install?)
function check_required_software() {

        # check if the command is available on path
        which $1 > /dev/null

        if [ $? != 0 ]
                then
                        echo "you have to install $1 before starting the cluster (e.g. $2 )!"
                        exit
        fi
}




# ------------------------------------------------------------------------ RESTORE THE SNAPSHOT WITH THE KIBANA DATA --- #
# signature:
# - (no params)
function restore_kibana_snapshot(){

    echo "restoring kibana from snapshot $snapshot_name..."

    elk_base_url="http://10.0.3.101:9200"



    # create the snapshot repository in elk
    curl -XPUT -k -s "$elk_base_url/_snapshot/elk_backup" -d '{
          "type": "fs",
          "settings": {
              "location": "/tmp/elkinstalldir/snapshots/"
          }
      }'

    # close the kibana index, restore it from snapshot, and reopen it
    curl -XPOST -k -s "$elk_base_url/.kibana/_close"
    curl -XPOST -k -s "$elk_base_url/_snapshot/elk_backup/$snapshot_name/_restore"
    curl -XPOST -k -s "$elk_base_url/.kibana/_open"

}

clear
echo ""
echo ""
echo "interactive cluster starter"
echo "written by Tobias Schaber, codecentric AG"
echo ""	
echo "---------------------------------------------------------"
echo "Welcome to the elasticsearch interactive cluster starter."
echo "This script will ask you some things about your desired  "
echo "cluster and will then start this cluster up for you.     "
echo "---------------------------------------------------------"
echo ""
echo ""

# variable building the vagrant machine list to start

echo "Checking required software..."
check_required_software vagrant vagrant
check_required_software java openjdk-7-jdk
check_required_software keytool openjdk-7-jdk
check_required_software openssl openssl
check_required_software virtualbox virtualbox
check_vagrant_plugin vagrant-hosts
echo "Done. All required software installed."
start_kibana=yes
setup_kibana=yes
use_logstash=yes
use_redis=no
snapshot_name=kibdefault
vagrant_machine_list="elkmaster1 elkdata1 logstash1"

echo "---------------------------------------------------------"
echo "Collecting data finished. Summary:"
echo "vagrant startup line:        vagrant up $vagrant_machine_list"
echo "start kibana?                $start_kibana"
echo "setup kibana from snapshot?: $setup_kibana"
echo "Snapshot name:               $snapshot_name"
echo "---------------------------------------------------------"

# start elkmaster2 and suspend it before starting the cluster
vagrant up elkmaster2
vagrant suspend elkmaster2

vagrant up $vagrant_machine_list

if [ $setup_kibana == "yes" ]
then
    restore_kibana_snapshot
fi



echo "---------------------------------------------------------"
echo "Finished! The ELK cluster should now be online: http://10.0.3.101:5601"



