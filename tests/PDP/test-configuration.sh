#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

#################################################################
echo "1) testing pdp status"

$T_PDP_CTRL status | grep -q "argus-pdp is running..."
if [ $? -eq 0 ]; then
  echo "OK"
else
  failed="yes"
  echo "Failed"
fi

if [ $failed == "yes" ]; then
  echo "---Test-PDP-Configuration: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-PDP-Configuration: TEST PASSED---"
  echo `date`
  exit 0
fi

