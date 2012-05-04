#!/bin/bash

# Make sure all the needed Variables are present and all the Argus-components are up and running
source $FRAMEWORK/set_homes.sh
source $FRAMEWORK/start_services.sh

# Start test

#################################################################
echo "1) testing missing configuration file"

rm -f $T_PAP_CONF/$T_PAP_CONF_INI
$T_PAP_CTRL restart >>/dev/null
sleep 10
$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  cp -f $SCRIPTBACKUPLOCATION/$T_PAP_CONF_INI $T_PAP_CONF/$T_PAP_CONF_INI
  echo "FAILED"
else
  cp -f $SCRIPTBACKUPLOCATION/$T_PAP_CONF_INI $T_PAP_CONF/$T_PAP_CONF_INI
  $T_PAP_CTRL start >>/dev/null
  sleep 40
  echo "OK"
fi

#################################################################
echo "2) testing missing argus file"
rm -f $T_PAP_CONF/$T_PAP_AUTH_INI

$T_PAP_CTRL restart >>/dev/null
sleep 10
$T_PAP_CTRL status | grep -q 'PAP running'
if [ $? -eq 0 ]; then
  failed="yes"
  echo "FAILED"
  cp -f $SCRIPTBACKUPLOCATION/$T_PAP_AUTH_INI $T_PAP_CONF/$T_PAP_AUTH_INI
else
  cp -f $SCRIPTBACKUPLOCATION/$T_PAP_AUTH_INI $T_PAP_CONF/$T_PAP_AUTH_INI
  $T_PAP_CTRL start >>/dev/null
  sleep 40
  echo "OK"
fi

#################################################################
#start/restart the server
$T_PAP_CTRL status | grep -q 'PAP not running'
if [ $? -eq 0 ]; then
  $T_PAP_CTRL start >>/dev/null
else
  $T_PAP_CTRL restart >>/dev/null
fi
sleep 10

if [ $failed == "yes" ]; then
  echo "---Test-PAP-FUNC-2: TEST FAILED---"
  echo `date`
  exit 1
else
  echo "---Test-PAP-FUNC-2: TEST PASSED---"
  echo `date`
  exit 0
fi

