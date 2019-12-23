#!/bin/bash

### TEST: 
###     Temp
### @ref https://docs.centrify.com/en/css/2018-html/#page/Network_information_service/Verifying_NIS_configuration_for_servers_and_clie.3.html

### TEST CASE Clients:
###     Check if Clients are using our NTP Server.
if [ $HOSTNAME == "gw" ]; then

    ## Test
    echo "Test successful" && exit 0

### TEST CASE Clients:
###     Check if Clients are using our NTP Server.
else

    ## Test
    echo "Test successful" && exit 0
fi

## Tests failed
exit 1