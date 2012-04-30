#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Make sure we do NOT have a PAP running at start

$T_PAP_CTRL stop > /dev/null 2>&1;
sleep 3;
$T_PAP_CTRL status > /dev/null 2>&1;
result=$?
if [ $? -ne 0 ]; then
  echo "$T_PAP_CTRL status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "$T_PAP_CTRL status returned ${result}. OK."
fi

/etc/init.d/$T_PDP_CTRL stop > /dev/null 2>&1;
sleep 3;
/etc/init.d/$T_PDP_CTRL status > /dev/null 2>&1;
result=$?; 
if [ $? -ne 0 ]; then
  echo "pdp status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "pdp status returned ${result}. OK."
fi

/etc/init.d/pepd stop > /dev/null 2>&1;
sleep 3;
/etc/init.d/pepd status > /dev/null 2>&1;
result=$?;
if [ $? -ne 0 ]; then
  echo "pepd status should return non-zero. returned ${result}."
  failed="yes"
  exit 1
else
  echo "pepd status returned ${result}. OK."
fi

if [ $failed == "yes" ]; then
  echo "---${script_name}: TEST FAILED---"
  echo `date`
  exit 1
else 
  echo "---${script_name}: TEST PASSED---"
  echo `date`
  exit 0
fi

