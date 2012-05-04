#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"

echo `date`
echo "---Test-PAP-Ping---"
###############################################################
echo "1) test PAP ping"
$T_PAP_HOME/bin/pap-admin ping
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-PAP-Ping: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-PAP-Ping: TEST PASSED---"
  echo `date`
  exit 0
fi

