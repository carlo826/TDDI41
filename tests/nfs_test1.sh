#!/bin/bash

### TEST: 

### TEST CASE Server:
###     Check if NFS service is working properly
if [ $HOSTNAME == "server" ]; then

    ## Check if nfsd is running
    [[ $(ps aux | grep 'nfsd') ]] &&
    ## Check that server is exporting /usr/local
    [[ $(showmount -e | grep /usr/local) ]] &&
    echo "Test successful" && exit 0

### TEST CASE Clients:
###     Check if Clients are using the NFS server
else
    ## Check if client mounting /usr/local from server
    [[ $(df | grep '10.0.0.2:/usr/local') ]] &&
    echo "Test successful" && exit 0
fi

## Tests failed
exit 1
