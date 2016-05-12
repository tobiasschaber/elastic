#!/bin/bash


# ------------------------------------------------------------------------ ASK FOR MACHINE COUNT --- #
# signature:
# $1: telling name (e.g. logstash, master, data)
# $2: machine name (e.g. logstashindexer, elkmaster, elkdata)
# $3: max count
function ask_for_machine_count() {
        local count

        # ask user for machine count
        read -p "How many $1 nodes do you want? ([1]-$3) :" count
        
        # check if user pushed [enter] for default value
        if [ -z "$count" ]
                then
                count=1
        fi

        # check if user input is a number
        if ! [[ $count =~ ^[0-9] ]]
                then
                        echo "invalid input: \"$count\" is not a number."
                        exit
        fi

        # check if user input is greater than allowed
        if [ $count -gt $3 ]
                then
                        echo "invalid input: \"$count\" is to much. maximum is: \"$3\"."
                        exit
        fi

        local i=1
        while [ $i -le $count ]
                do
                        # append the machine to the machine list.
                        # space is at the end
                        vagrant_machine_list="$vagrant_machine_list$2$i "
                        let i=$i+1
        done

        return $count
}


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


# ------------------------------------------------------------------------ ASK IF USE LOGSTASH --- #
# signature:
# - (no params)
function ask_for_logstash_setup() {

        # ask if logstash should be used
        read -p "Do yowant to use logstash? ([yes]/no) :" use_logstash


        # check if user pushed [enter] for default value
        if [ -z "$use_logstash" ]
                then
                        use_logstash="yes"
        fi


        if [ $use_logstash == "yes" ]
                then
                        read -p "Do you want a default setup (logstash only) or a redis setup? ([default]/redis):" logstash_mode
                        
                        # check if user pushed [enter] for default value
                        if [ -z "$logstash_mode" ]
                                then
                                        logstash_mode="default"
                        fi


                        if [ $logstash_mode == "default" ]
                                then
                                        use_redis="no"
                                else if [ $logstash_mode == "redis" ]
                                        then
                                                use_redis="yes"
                                        else
                                                echo "invalid logstash mode: \"$logstash_mode\" is not valid. \"redis\" or \"default\" are valid."
                                                exit
                                fi
                        fi
                else 
                        if [ $use_logstash != "no" ]
                                then
                                        echo "invalid logstash usage: \"$use_logstash\". valid are: \"yes\", \"no\"."
                        fi
        fi
}


# ------------------------------------------------------------------------ ASK IF KIBANA SHOULD BE STARTED --- #
# signature:
# - (no params)
function ask_to_start_kibana(){

        # ask if kibana should be started automatically
        read -p "Should I start Kibana for you? ([yes]/no) :" start_kibana
        
        # check if user pushed [enter] for default value
        if [ -z "$start_kibana" ]
                then
                start_kibana="yes"
        fi

        if [ ! $start_kibana == "yes" ] && [ ! $start_kibana == "no" ]
                then
                        echo "invalid input: \"$start_kibana\" is not valid for start kibana. valid are: yes, no"
                        exit
        fi
}


# ------------------------------------------------------------------------ ASK IF KIBANA DATA SHOULD BE RESTORED FROM SNAPSHOT --- #
# signature:
# - (no params)
function ask_to_setup_kibana(){

        # ask if kibana should be set up from snapshot
        read -p "Should I setup kibana from snapshot? (yes/[no]) :" setup_kibana
        
        # check if user pushed [enter] for default value
        if [ -z "$setup_kibana" ]
                then
                setup_kibana="no"
        fi

        if [ ! $setup_kibana == "yes" ] && [ ! $setup_kibana == "no" ]
                then
                        echo "invalid input: \"$setup_kibana\" is not valid for setup kibana. valid are: yes, no"
                        exit
        fi

        # check if the shared file system in vagrant is not commented out
        if grep -q -e "\s*#\s*config.vm.synced_folder" Vagrantfile;
                then
                        echo "Error: the shared folder is commented out in your vagrantfile."
                        echo "remove the \"#\" in the line: #   config.vm.synced_folder to proceed."
                        exit
                        
        fi
}


# ------------------------------------------------------------------------ START KIBANA ON ALL (ELKCLIENT) NODES --- #
# signature:
# - (no params)
function startup_kibana_on_all_nodes(){

        local i=1
        while [ $i -le $client_node_count ]
                do
                        # start kibana which is not started automatically
                        # try to start with systemctl and then with service command
                        vagrant ssh elkclient$i -c "sudo systemctl start kibana"
                        vagrant ssh elkclient$i -c "sudo service kibana start"
                        let i=$i+1
        done

}

# ------------------------------------------------------------------------ ASK FOR THE KIBANA SNAPSHOT NAME --- #
# signature:
# - (no params)
function ask_for_kibana_snapshot_name(){

        # ask for the snapshot name
        read -p "Which snapshot should be restored? Enter name: [kibdefault] :" snapshot_name

        # check if user pushed [enter] for default value
        if [ -z "$snapshot_name" ]
                then
                snapshot_name="kibdefault"
        fi

        # check if the snapshot file exists
        if [ ! -f "snapshots/meta-$snapshot_name.dat" ]
                then
                	echo "invalid input: the snapshot does not exist in the \"snaphots\" directory."
                        exit
        fi
}


# ------------------------------------------------------------------------ RESTORE THE SNAPSHOT WITH THE KIBANA DATA --- #
# signature:
# - (no params)
function restore_kibana_snapshot(){

    echo "restoring kibana from snapshot $snapshot_name..."

    # check if SSL is enabled
    if grep -q -e "\s*http.ssl:\s*true" hiera/common.yaml;
    then
        elk_base_url="https://10.0.3.131:9200"
    else
        elk_base_url="http://10.0.3.131:9200"
    fi

    # check if authentication is enabled
    if grep -q -e "\s*enable_authentication:\s*true" hiera/common.yaml;
    then
        echo "authentication is enabled"
        elk_username=$(less hiera/common.yaml | grep -e "\ſ*[^\._]username" | cut -d : -f2 | tr -d ' ')
        elk_password=$(less hiera/common.yaml | grep -e "\ſ*[^\._]password" | cut -d : -f2 | tr -d ' ')

        # create the snapshot repository in elk
        curl -XPUT -k -u $elk_username:$elk_password -s "$elk_base_url/_snapshot/elk_backup" -d '{
              "type": "fs",
              "settings": {
                  "location": "/tmp/elkinstalldir/snapshots/"
              }
          }'

        # close the kibana index, restore it from snapshot, and reopen it
        curl -XPOST -k -u $elk_username:$elk_password -s "$elk_base_url/.kibana/_close"
        curl -XPOST -k -u $elk_username:$elk_password -s "$elk_base_url/_snapshot/elk_backup/$snapshot_name/_restore"
        curl -XPOST -k -u $elk_username:$elk_password -s "$elk_base_url/.kibana/_open"

    else
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

    fi


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

# variable building the vagrant machine liste to start
vagrant_machine_list=""
echo "Checking required software..."
check_required_software vagrant vagrant
check_required_software java openjdk-7-jdk
check_required_software keytool openjdk-7-jdk
check_required_software openssl openssl
check_required_software virtualbox virtualbox
check_vagrant_plugin vagrant-hosts
echo "Done. All required software installed."
# ------------------------------------------------------------------------ CHECK STANDARD NODES --- #
ask_for_machine_count "master" "elkmaster" 2
ask_for_machine_count "data" "elkdata" 3
ask_for_machine_count "client" "elkclient" 2
client_node_count=$?
ask_to_start_kibana

if [ $start_kibana == "yes" ]
then
    ask_to_setup_kibana
fi

if [ $setup_kibana == "yes" ]
then
    ask_for_kibana_snapshot_name
fi

# ------------------------------------------------------------------------ CHECK LOGSTASH NODES --- #
ask_for_logstash_setup

if [ $use_logstash == "yes" ]
then
    if [ $use_redis == "no" ]
    then
        ask_for_machine_count "logstash" "logstash" 1
    else
        ask_for_machine_count "logstash shipper" "logstashshipper" 2
        ask_for_machine_count "logstash indexer" "logstashindexer" 2
        ask_for_machine_count "redis" "redis" 2
    fi
fi

# ------------------------------------------------------------------------ DATA COLLECTION FINISHED. START CLUSTER NOW --- #

echo "---------------------------------------------------------"
echo "Collecting data finished. Summary:"
echo "vagrant startup line:        vagrant up $vagrant_machine_list"
echo "start kibana?                $start_kibana"
echo "setup kibana from snapshot?: $setup_kibana"
echo "Snapshot name:               $snapshot_name"
echo "---------------------------------------------------------"
echo "Finished collecting. Press [enter] to start the cluster..."

read

vagrant up $vagrant_machine_list

if [ $setup_kibana == "yes" ]
then
    restore_kibana_snapshot
fi

if [ $start_kibana == "yes" ]
then

    startup_kibana_on_all_nodes

    if grep -q -e "\s*installkibana::configkibana::enablehttps:\strue" hiera/common.yaml;
    then
        echo "Kibana should now be available under: https://10.0.3.131:5601"
    else
        echo "Kibana should now be available under: http://10.0.3.131:5601"
    fi
fi

echo "---------------------------------------------------------"
echo "Finished! The ELK cluster should now be online!"