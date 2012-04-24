#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"

echo `date`
echo "---Test-Update-PAP---"
###############################################################
echo "1) testing upap with non existing alias"
$T_PAP_HOME/bin/pap-admin upap Dummy
if [ $? -eq 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
if [ $failed == "yes" ]; then
  echo "---Test-Update-PAP: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Update-PAP: TEST PASSED---"
  echo `date`
  exit 0
fi

