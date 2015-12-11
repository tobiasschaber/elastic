#!/bin/bash

# This script will download the java 8 RPM and install it into yum.
# The download will only happen if the file does not already exists
# to improve the procedure performance. The RPM will be stored in a
# temporary folder in the installation directory which is shared by
# all vagrant instances.


# download the java rpm file into a shared temporary location to avoid multiple downloads
if [ ! -f "$ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm" ]
then
        echo "Downloading Java"
        sudo mkdir $ELKINSTALLDIR/installation/tmp
        # download the oracle java 8 rpm
        sudo wget -q \
        --no-cookies \
        -O $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm \
        --no-check-certificate \
        --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.rpm"
fi

# install the oracle java 8 rpm in yum
sudo rpm -ivh $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm
