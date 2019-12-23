#!/bin/bash

### TEST: 
###     Temp
### @ref https://docs.centrify.com/en/css/2018-html/#page/Network_information_service/Verifying_NIS_configuration_for_servers_and_clie.3.html

### TEST CASE Clients:
###     Check if Clients are using our NTP Server.
if [ $HOSTNAME == "server" ]; then

    ## Check if ypserv & ypbind is running
    [[ $(rpcinfo -u localhost ypserv | grep 'program 100004') ]] &&
    [[ $(rpcinfo -u localhost ypbind | grep 'program 100007') ]] &&
    ## Check if the NIS map contains correct data
    [[ $(rpcinfo | grep 'ypserv') ]] &&
    echo "Test successful" && exit 0

### TEST CASE Clients:
###     Check if Clients are using our NTP Server.
else

    ## Check if ypserv & ypbind is running
    [[ $(rpcinfo -u localhost ypbind | grep 'program 100007') ]] &&
    [[ $(ypwhich | grep '10.0.0.2') ]] &&
    echo "Test successful" && exit 0
fi

## Tests failed
exit 1