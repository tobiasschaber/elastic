#!/bin/bash

echo "Starting up the application server for demo"

if [ ! -d "/etc/demo" ]; then
    sudo mkdir /etc/demo
fi

sudo cp -r /vagrant/demo/demo-app/out/artifacts/demo_app_jar/*.* /etc/demo

nohup java -jar /etc/demo/demo-app.jar &