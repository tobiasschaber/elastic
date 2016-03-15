#!/bin/bash

# this script will snapshot your kibana data

# usage: ./snapshotKibana.sh <snapshotname>

if [ -z "$1" ]
        then
                echo "parameter for snapshot name is missing."
                echo "usage: ./snapshotKibana.sh <snapshotname>"
                exit
fi

echo "saving snapshot under $1"


# create the snapshot repository in elk
curl -XPUT -s "http://10.0.3.131:9200/_snapshot/elk_backup" -d '{
      "type": "fs",
      "settings": {
          "location": "/tmp/elkinstalldir/snapshots/"
      }
  }'


# create the snapshot
curl -XPUT -s "http://10.0.3.131:9200/_snapshot/elk_backup/$1?wait_for_completion=true" -d '{
      "indices": ".kibana"
    }'
