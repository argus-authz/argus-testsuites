#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"

echo `date`
echo "---Test-Refesh-Cache---"
###############################################################
echo "1) testing rc with non existing alias"
$T_PAP_HOME/bin/pap-admin rc Do-Not-Exist
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) testing rc with a local pap"
$T_PAP_HOME/bin/pap-admin rc default
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Refesh-Cache: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Refesh-Cache: TEST PASSED---"
  echo `date`
  exit 0
fi

