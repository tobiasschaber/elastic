#!/bin/bash

# this script will restore the snapshot with your kibana data

# usage: ./restoreSnapshotKibana.sh <snapshotname>

if [ -z "$1" ]
        then
                echo "parameter for snapshot name is missing."
                echo "usage: ./snapshotKibana.sh <snapshotname>"
                exit
fi

echo "restoring snapshot $1"

# create the snapshot repository in elk
curl -XPUT -s "http://10.0.3.131:9200/_snapshot/elk_backup" -d '{
      "type": "fs",
      "settings": {
          "location": "/tmp/elkinstalldir/snapshots/"
      }
  }'


# close the kibana index, restore it from snapshot, and reopen it
curl -XPOST -s "http://10.0.3.131:9200/.kibana/_close"
curl -XPOST -s "http://10.0.3.131:9200/_snapshot/elk_backup/$1/_restore"
curl -XPOST -s "http://10.0.3.131:9200/.kibana/_open"

echo "IF YOU HAVE ACCESS_DENIED_EXCEPTION, UNCOMMENT THE SHARED FOLDER LINE IN YOUR VAGRANTFILE!"
