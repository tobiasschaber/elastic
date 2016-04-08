#!/bin/bash



echo "Starting up the application server for demo"

if [ ! -d "/etc/demo" ]; then
    sudo mkdir /etc/demo
fi

if [ ! -d "/etc/demo/logs" ]; then
    sudo mkdir /etc/demo/logs
fi

sudo tar -xvzf /tmp/elkinstalldir/demo/access_logs.tar.gz -C /etc/demo/logs

sudo chmod 777 /etc/demo/logs/access*

sudo cp -r /vagrant/demo/demo-app/out/artifacts/demo_app_jar/*.jar /etc/demo

cd /etc/demo
sudo java -jar demo-app.jar &


