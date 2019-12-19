#!/bin/bash

hs=$(echo $HOSTNAME)

# Copy
cp -r /root/tddi41_redo/etc/${hs}/* /etc

# Restart all services
/etc/init.d/networking restart
/etc/init.d/bind9 restart
/etc/init.d/ntp restart