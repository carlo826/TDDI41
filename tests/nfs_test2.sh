#!/bin/bash

### TEST: 

### TEST CASE Server:
###     Show that /home1 and /home2 are being exported with appropriate permissions
if [ $HOSTNAME == "server" ]; then

    ## Check if nfsd is running
    [[ $(ps aux | grep 'nfsd') ]] &&
    ## Check that server is exporting /homee1 and /home2
    [[ $(showmount -e | grep '/home1') ]] &&
    [[ $(showmount -e | grep '/home2') ]] &&
    echo "Test successful" && exit 0


## Tests failed
exit 1
