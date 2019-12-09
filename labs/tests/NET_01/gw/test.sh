#!/bin/bash

if [ $HOSTNAME == "gw" ]; then
  echo "Test passed!"
else
  echo "Test failed: Incorrect hostname"
fi
