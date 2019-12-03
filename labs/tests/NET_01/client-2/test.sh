#!/bin/bash

if [ $HOSTNAME == client-2 ]; then
  echo "Test passed!"
else
  echo "Test failed: Incorrect hostname"
fi
