#!/bin/bash

if [ $HOSTNAME == "client-1" ]; then
  echo "Test passed!"
else
  echo "Test failed: Incorrect hostname"
fi
