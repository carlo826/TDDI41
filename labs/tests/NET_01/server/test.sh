#!/bin/bash

if [ $HOSTNAME == "server" ]; then
  echo "Test passed!"
else
  echo "Test failed: Incorrect hostname"
fi
