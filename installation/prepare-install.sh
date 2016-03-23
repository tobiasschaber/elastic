#!/bin/bash

# set the home of the installer directory
export ELKINSTALLDIR="/vagrant";


# create a symlink under /tmp/elkinstalldir,
# where the installer location directory will be
sudo ln -s $ELKINSTALLDIR /tmp/elkinstalldir

# run the preparation script for java
source $ELKINSTALLDIR/installation/prepare-java.sh

# run the preparation script for puppet
source $ELKINSTALLDIR/installation/prepare-puppet.sh


echo "--------------------------------------------------------"
echo "ELKINSTALLDIR is now mapped to $ELKINSTALLDIR."
echo "finished preparation!"
echo "--------------------------------------------------------"
