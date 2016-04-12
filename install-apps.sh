#!/bin/bash



echo "Starting up the application server for demo"

if [ ! -d "/etc/demo" ]; then
    sudo mkdir /etc/demo
fi

if [ ! -d "/etc/demo/logs" ]; then
    sudo mkdir /etc/demo/logs
else
    sudo rm /etc/demo/logs/access_log*
fi

sudo touch /etc/demo/logs/access_log-20141019

if [ ! -f "/tmp/elkinstalldir/demo/GeoLiteCity.dat" ]; then
    cd /tmp/elkinstalldir/demo
    sudo gunzip -k GeoLiteCity.dat.gz

fi

if [ ! -f "/etc/logstash/GeoLiteCity.dat" ]; then
    sudo cp /tmp/elkinstalldir/demo/GeoLiteCity.dat /etc/logstash

fi


sudo cp /tmp/elkinstalldir/demo/GeoLiteCity.dat /etc/logstash/GeoLiteCity.dat

sudo tar -xvzf /tmp/elkinstalldir/demo/access_logs.tar.gz -C /tmp

sudo less /tmp/access_log-20141019 >> /etc/demo/logs/access_log-20141019

sudo chmod 777 /etc/demo/logs/access*

sudo cp -r /vagrant/demo/demo-app/out/artifacts/demo_app_jar/*.jar /etc/demo

cd /etc/demo
sudo java -jar demo-app.jar &


