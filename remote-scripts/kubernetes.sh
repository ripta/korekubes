#!/bin/sh

sleep 15
sudo mkdir -p /opt/bin
sudo tar zxf /tmp/kubernetes.tar.gz -C /opt/bin
sudo chmod +x /opt/bin/*
sudo chown root:root -R /opt/bin
sudo tar zxf /tmp/services.tar.gz -C /etc/systemd/system
rm -f /tmp/*.tar.gz
