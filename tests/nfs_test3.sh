#!/bin/bash

### TEST: 

### TEST CASE Server:
###     Check if the the automounter is working properly
if [ $HOSTNAME == "server" ]; then
    ## Check if autofs is running
    [[ $(ps aux | grep 'autofs') ]] &&
    echo "Test successful" && exit 0

### TEST CASE Clients:
###     Check if the the automounter is working properly
else
    ## Check that home1 is not already mounted
    [[ ! $(ls /home | grep 'home1') ]] &&
    ## Check that home1 is mounted when entered into and that it contains user1
    [[ $(cd /home/home1 && ls | grep 'user1') ]] &&
    echo "Test successful" && exit 0
fi

## Tests failed
exit 1
