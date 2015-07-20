#!/bin/sh

sudo mv /tmp/services/*.service /etc/systemd/system
sudo chown -R root:root /etc/systemd/system
rm -r /tmp/services
