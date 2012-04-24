#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

failed="no"
standard_poll_intervall=14400
poll_intervall=100

echo `date`
echo "---Test-Set/Get-Poll-Interval---"
###############################################################
echo "1) Setting polling time"
$T_PAP_HOME/bin/pap-admin spi $poll_intervall
if [ $? -ne 0 ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################
echo "2) Retrieving polling time"
time=`$T_PAP_HOME/bin/pap-admin gpi | sed 's/Polling interval in seconds: //g'`
if [ $time -ne $poll_intervall ]; then
  echo "Failed"
  failed="yes"
else
  echo "OK"
fi

###############################################################

$T_PAP_HOME/bin/pap-admin spi $standard_poll_intervall
if [ $? -ne 0 ]; then
  echo "Could not reset the poll intervall time to a default $standard_poll_intervall"
fi

if [ $failed == "yes" ]; then
  echo "---Test-Set/Get-Poll-Interval: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---Test-Set/Get-Poll-Interval: TEST PASSED---"
  echo `date`
  exit 0
fi

