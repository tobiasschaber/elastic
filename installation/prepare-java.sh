#!/bin/bash

# This script will download the java 8 RPM and install it into yum.
# The download will only happen if the file does not already exists
# to improve the procedure performance. The RPM will be stored in a
# temporary folder in the installation directory which is shared by
# all vagrant instances.



function install_java_by_rpm(){

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

    sudo rpm -ivh $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.rpm
}


function install_java_by_tar_gz(){

    # download the java rpm file into a shared temporary location to avoid multiple downloads
    if [ ! -f "$ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.tar.gz" ]
    then
            echo "Downloading Java"
            sudo mkdir $ELKINSTALLDIR/installation/tmp
            # download the oracle java 8 rpm
            sudo wget -q \
            --no-cookies \
            -O $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.tar.gz \
            --no-check-certificate \
            --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.tar.gz"
    fi

    sudo mkdir /opt/Oracle_Java/
    sudo tar -xvzf $ELKINSTALLDIR/installation/tmp/jdk-8u65-linux-x64.tar.gz -C /opt/Oracle_Java/
    sudo update-alternatives --install "/usr/bin/java" "java" "/opt/Oracle_Java/jdk1.8.0_65/bin/java" 1
    sudo update-alternatives --install "/usr/bin/javac" "javac" "/opt/Oracle_Java/jdk1.8.0_65/bin/javac" 1
    sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/opt/Oracle_Java/jdk1.8.0_65/bin/javaws" 1
    sudo update-alternatives --install "/usr/bin/jar" "jar" "/opt/Oracle_Java/jdk1.8.0_65/bin/jar" 1
    sudo update-alternatives --set "java" "/opt/Oracle_Java/jdk1.8.0_65/bin/java"
    sudo update-alternatives --set "javac" "/opt/Oracle_Java/jdk1.8.0_65/bin/javac"
    sudo update-alternatives --set "javaws" "/opt/Oracle_Java/jdk1.8.0_65/bin/javaws"
    sudo update-alternatives --set "jar" "/opt/Oracle_Java/jdk1.8.0_65/bin/jar"

}


# search for a package manager to use

which apt-get > /dev/null
if [ $? == 0 ]; then installer_mode="aptget"; fi

which yum > /dev/null
if [ $? == 0 ]; then installer_mode="yum"; fi


# for Ubuntu
if [ $installer_mode == "aptget" ]
    then
    install_java_by_tar_gz
fi


# for CentOS
if [ $installer_mode == "yum" ]
    then
    install_java_by_rpm
fi

