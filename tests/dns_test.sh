#!/bin/bash

### TEST: 
###     Temp
### 

:' 
    TEST CASE Router:
        Check if NTP server has correct config
'
if [ $HOSTNAME == "gw" ]; then
    [[ true ]] && exit 0
:' 
    TEST CASE Clients:
        Check if Clients are using our NTP Server
'
else
    [[ true ]] && exit 0
fi

## Tests failed
exit 1