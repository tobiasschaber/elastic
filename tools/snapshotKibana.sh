#!/bin/bash

# this script will snapshot your kibana data

# usage: ./snapshotKibana.sh <snapshotname>

if [ -z "$1" ]
        then
                echo "parameter for snapshot name is missing."
                echo "usage: ./snapshotKibana.sh <snapshotname>"
                exit
fi


# ask user for machine count
hostname='10.0.3.131'

read -p "please enter the ELK client hostname (default: 10.0.3.131) :" hostname

# check if user pushed [enter] for default value
if [ -z "$hostname" ]
		then
		hostname="10.0.3.131"
fi

echo "saving snapshot under $1"


# check if SSL is enabled
if grep -q -e "\s*http.ssl:\s*true" hiera/common.yaml;
then
	elk_base_url="https://$hostname:9200"
else
	elk_base_url="http://$hostname:9200"
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



snapshotRepoCmd="curl -XPUT -s $authString \"$elk_base_url/_snapshot/elk_backup\" -d '{
      "type": "fs",
      "settings": {
          "location": "/tmp/elkinstalldir/snapshots/"
      }
  }'"
  
  
snapshotCreateCmd="curl -XPUT -s $authString \"$elk_base_url/_snapshot/elk_backup/$1?wait_for_completion=true\" -d '{
      "indices": ".kibana"
    }'"

echo "creating snapshot repo...";
eval $snapshotRepoCmd;

echo "saving snapshot...";
eval $snapshotCreateCmd;
