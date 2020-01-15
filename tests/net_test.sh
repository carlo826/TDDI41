#!/bin/bash
arr=("gw" "server" "client-1" "client-2")
echo "Test gw(1), server(2), client-1(3), client-2(4)?
read -n 1 -p "Selection:" input

if [ $HOSTNAME == arr[input] ]; then
    echo "Test successful" && exit 0
fi

exit 1