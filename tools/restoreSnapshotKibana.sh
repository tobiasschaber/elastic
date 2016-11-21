#!/bin/bash

# this script will restore the snapshot with your kibana data

# usage: ./restoreSnapshotKibana.sh <snapshotname>

if [ -z "$1" ]
        then
                echo "parameter for snapshot name is missing."
                echo "usage: ./snapshotKibana.sh <snapshotname>"
                exit
fi

read -p "please enter the ELK client hostname (default: 10.0.3.131) :" hostname

# check if user pushed [enter] for default value
if [ -z "$hostname" ]
		then
		hostname="10.0.3.131"
fi

echo "restoring snapshot from $1"




# check if SSL is enabled
if grep -q -e "\s*http.ssl.enabled:\s*true" hiera/common.yaml;
then
	elk_base_url="https://$hostname:9200"
	unsecureFlag=" --insecure ";
else
	elk_base_url="http://$hostname:9200"
	unsecureFlag=" ";
fi



# check if authentication is enabled
authString=""
if grep -q -e "\s*enable_authentication:\s*true" hiera/common.yaml;
	then
	echo "authentication is enabled"
	elk_username=$(less hiera/common.yaml | grep -e "\ſ*[^\._]username" | cut -d : -f2 | tr -d ' ')
	elk_password=$(less hiera/common.yaml | grep -e "\ſ*[^\._]password" | cut -d : -f2 | tr -d ' ')
	authString="-u $elk_username:$elk_password"
fi



snapshotRepoCmd="curl $unsecureFlag -s -XPUT $authString \"$elk_base_url/_snapshot/elk_backup\" -d '{
      \"type\": \"fs\",
      \"settings\": {
          \"location\": \"/tmp/elkinstalldir/snapshots/\"
      }
  }'"

  echo $snapshotRepoCmd;

# close the kibana index, restore it from snapshot, and reopen it
closeKibanaIndexCmd="curl $unsecureFlag -s -XPOST  $authString \"$elk_base_url/.kibana/_close\""
restoreSnapshotCmd="curl $unsecureFlag -s -XPOST $authString \"$elk_base_url/_snapshot/elk_backup/$1/_restore\""
reopenKibanaIndexCmd="curl $unsecureFlag -s -XPOST  $authString \"$elk_base_url/.kibana/_open\""


echo "creating repo..."
eval $snapshotRepoCmd

echo $closeKibanaIndexCmd
eval $closeKibanaIndexCmd

echo $restoreSnapshotCmd
eval $restoreSnapshotCmd

echo $reopenKibanaIndexCmd
eval $reopenKibanaIndexCmd

echo "IF YOU HAVE ACCESS_DENIED_EXCEPTION, UNCOMMENT THE SHARED FOLDER LINE IN YOUR VAGRANTFILE!"