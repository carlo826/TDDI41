#!/bin/bash

### TEST: 
###     Install and configure NTP server and clients

### TEST CASE Router:
###     Check if NTP server has correct config.
if [ $HOSTNAME == "gw" ]; then
    # Check if noquery/nomodify is set
    [[ $(cat /etc/ntp.conf | grep 'nomodify nopeer noquery') ]] &&
    # Check if correct server is set
    [[ $(cat /etc/ntp.conf | grep 'server se.pool.ntp.org') ]] &&
    # Check if mode set to unicast
    [[ $(ntpq -p | grep ' u ') ]] &&
    echo "Router test successful" && exit 0


### TEST CASE Clients:
###     Check if Clients are using our NTP Server.
else
    # Check if client is using our NTP server & is synced
    [[ $(ntpq -p | grep '*10.0.0.1') ]] &&
    # Check if mode set to unicast
    [[ $(ntpq -p | grep ' u ') ]] &&
    echo "Client test successful" && exit 0
fi

## Tests failed
echo "Tests failed" && exit 1